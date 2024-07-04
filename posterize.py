from PIL import ImageFilter
from PIL import Image, ImageOps
# Load the image
original_image_path = './1.jpg'
img = Image.open(original_image_path)

# Apply Gaussian blur to the original image to smooth edges
blurred_img = img.filter(ImageFilter.GaussianBlur(radius=3))  # Adjust the radius to increase/decrease smoothing
pink_filter = Image.new('RGB', blurred_img.size, (255, 192, 203)) 
img_pink = Image.blend(blurred_img, pink_filter, alpha=0.3)
# Posterize the blurred image
posterized_blurred_img = ImageOps.posterize(img_pink, 4)  # Using 4 bits per channel

# Crop to 9:16 format
#posterized_blurred_cropped_img = posterized_blurred_img.crop((left, top, right, bottom))

# Save the smoothed color edges image
smoothed_image_path = './2.jpg'
posterized_blurred_img.save(smoothed_image_path)

smoothed_image_path