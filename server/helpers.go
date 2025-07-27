package main

import (
	"context"
	"fmt"
	"image"
	"image/color"
	"io"
	"log"
	"net/http"
	"regexp"
	"strconv"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"google.golang.org/api/option"
)

func initializeFirebaseApp() (*firebase.App, error) {
	opt := option.WithCredentialsFile("firebase_config.json")
	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		return nil, fmt.Errorf("error initializing app: %v", err)
	}
	return app, nil
}

func (cfg *config) sendFirebaseMessage(token []string, message map[string]string) error {
	fbMessage := &messaging.MulticastMessage{Data: message, Tokens: token}
	_, err := cfg.fbMessaging.SendEachForMulticast(context.Background(), fbMessage)
	if err != nil {
		return err
	}
	return nil
}

func returnAnError(w http.ResponseWriter, errorCode int, message string, err error) {
	w.WriteHeader(errorCode)
	w.Header().Add("Content-Type", "text/plain")
	w.Write([]byte(message))
	log.Printf("%v", err)
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

func checkAndChangeImageOrientation(img *image.Gray) *image.Gray { // rotate the image to the right (to get it vertical) somehow we get it in landscape from the app
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
