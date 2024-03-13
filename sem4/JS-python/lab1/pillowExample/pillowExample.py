from PIL import Image
import os

# system path: 'C:/Users/aliks/Desktop/input'

input_path = 'input'
output_path = 'output'

for filename in os.listdir(input_path):
    if filename.endswith('.webp'):
        file_path = os.path.join(input_path, filename)

        image = Image.open(file_path)
        # image.show()
        image = image.resize((20, 20))

        png_filename = os.path.splitext(filename)[0] + '.png'
        png_file_path = os.path.join(output_path, png_filename)

        image.save(png_file_path, 'PNG')

        print(f'changed {filename} for {png_filename}')

print('success')
