package main

import "core:image/png"
import "core:image"
import "core:fmt"
import rl"vendor:raylib"
import "core:c"

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

draw_gray_image :: proc(img: []byte, width, height: int) {
    indice_pixel := 0
    for y in 0..<height {
        for x in 0..<width {
            if len(img) == indice_pixel {
                return
            }
            rl.DrawPixel(c.int(x), c.int(y), {img[indice_pixel], img[indice_pixel], img[indice_pixel], 255})
            indice_pixel += 1
        }
    }
}

main :: proc() {
    imagem_vasos, _ := png.load_from_bytes(vasos_byte_png)
    gray_image := make_it_gray(imagem_vasos)
    rl.InitWindow(1280, 720, "robert cross")
    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        draw_gray_image(gray_image, imagem_vasos.width, imagem_vasos.height)
        rl.EndDrawing()
    }
}