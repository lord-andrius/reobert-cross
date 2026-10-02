package main

import "core:image/png"
import "core:image"
import "core:fmt"
import rl"vendor:raylib"
import "core:c"
import "core:math"

vasos_byte_png := #load("vasos.png", []u8)

make_it_gray :: proc(img: ^image.Image, allocator := context.allocator) -> []byte {
    PESO_R :: 0.299
    PESO_G :: 0.578
    PESO_B :: 0.114
    result := make([]byte, img.width * img.height, allocator)
    indice_foto_original := 0
    for &pixel_cinza, indice_cinza in result {
        indice_foto_original = indice_cinza * (img.channels * (img.depth / 8))
        indice_foto_original_r := indice_foto_original
        indice_foto_original_g := indice_foto_original_r + (img.depth / 8)
        indice_foto_original_b := indice_foto_original_g + (img.depth / 8)
        pixel_cinza = byte(f32(img.pixels.buf[indice_foto_original_r]) * PESO_R + f32(img.pixels.buf[indice_foto_original_g]) * PESO_G + f32(img.pixels.buf[indice_foto_original_b]) * PESO_B / (PESO_R + PESO_G + PESO_B))
    }
    return result
}

make_it_edgy :: proc(gray_img: []byte, width, height: int, allocator := context.allocator) -> []byte {
	y_func :: proc(img: []byte, x, y, width, height: int) -> f32 {
		index := (y * width) + x
		return math.sqrt(f32(img[index]))
	}
	edgy_image := make([]byte, len(gray_img))
	for y in 0..<(height - 1) {
		for x in 0..<(width - 1) {
			index := (y * width) + x
			a := y_func(gray_img, x, y, width, height)
			b := y_func(gray_img, x + 1, y + 1, width, height)
			c := y_func(gray_img, x + 1, y, width, height)
			d := y_func(gray_img, x, y + 1, width, height)
			edgy_image[index] = byte(math.sqrt(math.pow(a - b, 2) + math.pow(c - d, 2)))
			edgy_image[index] *= 30
		}
	}
	return edgy_image
}

draw_one_channel_image :: proc(img: []byte, width, height: int, initial_x: c.int = 0, initial_y: c.int = 0) {
    indice_pixel := 0
    for y in 0..<height {
        for x in 0..<width {
            if len(img) == indice_pixel {
                return
            }
            rl.DrawPixel(c.int(x) + initial_x, c.int(y) + initial_y, {img[indice_pixel], img[indice_pixel], img[indice_pixel], 255})
            indice_pixel += 1
        }
    }
}

main :: proc() {
    imagem_vasos, _ := png.load_from_bytes(vasos_byte_png)
    gray_image := make_it_gray(imagem_vasos)
    edgy_image := make_it_edgy(gray_image, imagem_vasos.width, imagem_vasos.height)
    fmt.println(edgy_image)
    rl.InitWindow(1280, 720, "robert cross")
    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        draw_one_channel_image(gray_image, imagem_vasos.width, imagem_vasos.height)
        draw_one_channel_image(edgy_image, imagem_vasos.width, imagem_vasos.height, c.int(imagem_vasos.width))
        rl.EndDrawing()
    }
}
