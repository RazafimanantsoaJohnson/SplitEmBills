package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"image"
	"image/color"
	_ "image/jpeg"
	"image/png"
	"io"
	"mime"
	"net/http"
	"os"
	"os/exec"
	"regexp"
	"strconv"
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

func transformImage(file io.Reader, threshold uint8) (image.Image, error) { //to grayScale and then compare to the threshold to transform to black/white
	img, _, err := image.Decode(file)
	if err != nil {
		return nil, err
	}
	bounds := img.Bounds()
	grayImage := image.NewGray(bounds)

	for i := bounds.Min.X; i < bounds.Max.X; i++ {
		for j := bounds.Min.Y; j < bounds.Max.Y; j++ {
			originalColor := img.At(i, j)
			grayShade := color.GrayModel.Convert(originalColor).(color.Gray)
			grayImage.SetGray(i, j, grayShade)
			/*
				if grayShade.Y > threshold {
					// grayImage.SetGray(i, j, color.Gray{Y: 255})
				} else {
					//grayImage.SetGray(i, j, color.Gray{Y: 0})
				}
			*/
		}
	}

	return checkAndChangeImageOrientation(grayImage), nil
}

func checkAndChangeImageOrientation(img *image.Gray) *image.Gray {
	bounds := img.Bounds()
	if bounds.Max.X > bounds.Max.Y {
		x0 := bounds.Min.X
		y0 := bounds.Min.Y
		x1 := bounds.Max.X
		y1 := bounds.Max.Y
		rotatedRightImg := image.NewGray(image.Rect(y0, x0, y1, x1))
		for x := x0; x < x1; x++ {
			for y := y0; y < y1; y++ {
				rotatedRightImg.SetGray(y1-y, x, img.GrayAt(x, y))
			}
		}
		return rotatedRightImg
	}
	return img
}

func findItems(extractedData []string) []billItem {
	itemPriceRegex := regexp.MustCompile(`[0-9]+\.[0-9]{1,2}$`)
	result := []billItem{}
	// need to separate the price from the description
	for i := 0; i < len(extractedData); i++ {
		if itemPriceRegex.MatchString(extractedData[i]) {
			amount := itemPriceRegex.FindString(extractedData[i])
			description := itemPriceRegex.ReplaceAllString(extractedData[i], "")
			amountVal, _ := strconv.ParseFloat(amount, 32)
			result = append(result, billItem{
				Description: description,
				Amount:      float32(amountVal),
			})

		}
	}

	return result
}
