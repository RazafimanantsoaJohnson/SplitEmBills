package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	_ "image/jpeg"
	"image/png"
	"io"
	"mime"
	"net/http"
	"os"
	"os/exec"
	"strings"

	"github.com/RazafimanantsoaJohnson/SplitEmBills/internal/database"
	"github.com/google/uuid"
)

type billItem struct {
	Description string  `json:"description"`
	Amount      float32 `json:"amount"`
}

type paymentRoom struct {
	Id        string `json:"id"`
	CreatedBy string `json:"created_by"`
	Data      []billItem
}

func (cfg *config) handlerCreatePaymentRoom(w http.ResponseWriter, r *http.Request) {
	maxSize := 15 << 20
	err := r.ParseMultipartForm(int64(maxSize))
	if err != nil {
		returnAnError(w, 400, "unable to parse the received file", err)
		return
	}
	fileData, fileHeader, err := r.FormFile("bill")

	if err != nil {
		returnAnError(w, 500, "the server was enable to parse the file", err)
		return
	}
	defer fileData.Close()

	//checking the type of the file
	mimeHeader, _, err := mime.ParseMediaType(fileHeader.Header.Get("Content-Type"))
	if err != nil {
		returnAnError(w, 500, "the server was enable to parse the attached file type", err)
		return
	}
	fmt.Println(mimeHeader)
	fileType := strings.Split(mimeHeader, "/")[0]
	fileExt := strings.Split(mimeHeader, "/")[1]
	if fileType != "image" || (fileExt != "jpeg" && fileExt != "png") {
		returnAnError(w, 400, "unsupported file type (we only support .png .jpeg files)", err)
		return
	}
	curDir, _ := os.Getwd()

	grayImg, err := transformImage(fileData, 128)
	if err != nil {
		returnAnError(w, 500, "unable to process image", err)
		return
	}

	tempFile, err := os.CreateTemp(fmt.Sprintf("%v/tmp/", curDir), fmt.Sprintf("temporary_img.%v", fileExt))
	if err != nil {
		returnAnError(w, 500, "unable to create a file on the server", err)
		return
	}
	tempFile.Seek(0, io.SeekStart)
	defer os.Remove(tempFile.Name())

	err = png.Encode(tempFile, grayImg)
	if err != nil {
		returnAnError(w, 500, "unable to populate file data", err)
		return
	}

	extractedData, err := readImageData(tempFile.Name())
	if err != nil {
		returnAnError(w, 500, "unable to process image's text", err)
		return
	}
	splittedData := strings.Split(extractedData, "\n")
	//searching for 2 dec place characters
	allItems := findItems(splittedData)

	testUser, err := uuid.Parse("4c70caa7-b3ab-45c5-9ae2-f391de428aeb")
	jsonData, err := json.Marshal(&allItems)
	if err != nil {
		returnAnError(w, 500, "something went wrong when processing the data", err)
		return
	}

	newRoom, err := cfg.db.CreatePaymentRoom(context.Background(), database.CreatePaymentRoomParams{
		ID: uuid.New(),
		RawJsonData: sql.NullString{
			String: string(jsonData),
			Valid:  true,
		},
		CreatedBy: testUser,
	})
	if err != nil {
		returnAnError(w, 500, "an error happened when trying to create the new payment", err)
		return
	}

	newRoomResponse := paymentRoom{
		Id:        newRoom.ID.(string),
		Data:      allItems,
		CreatedBy: newRoom.CreatedBy.(string),
	}
	newRoomJson, err := json.Marshal(&newRoomResponse)
	if err != nil {
		returnAnError(w, 500, "error when preparing the response", err)
		return
	}
	w.Header().Add("Content-Type", "application/json")
	w.Write(newRoomJson)
}

func readImageData(path string) (string, error) {
	cmd := exec.Command("tesseract", path, "stdout")
	output, err := cmd.Output()
	if err != nil {
		fmt.Println("Error happend in when reading the file")
		fmt.Printf("%v", err)
		return "", err
	}
	return string(output), nil
}
