from math import cos, hypot, sin
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, PngImagePlugin


OUTPUT = Path(__file__).resolve().parent
SOURCE = OUTPUT.parents[1] / 'icons/obj/naga_tail_item.dmi'
SIZE = 32


def draw_tail():
    # Рисуем сразу в сетке 32×32, без уменьшения больших изображений и сглаживания.
    points = []
    distance = 0.0
    for index in range(1401):
        progress = index / 1400
        angle = -0.90 + progress * 10.6
        radius = 11.4 - progress * 10.4
        x = 16 + cos(angle) * radius
        y = 17 + sin(angle) * radius
        if points:
            distance += hypot(x - points[-1][0], y - points[-1][1])
        width = 3.25 * (1 - progress) + 0.48 * progress
        points.append((x, y, width, distance))

    image = Image.new('RGBA', (SIZE, SIZE))
    for y in range(SIZE):
        for x in range(SIZE):
            index = min(range(len(points)), key=lambda i: (x + 0.5 - points[i][0]) ** 2 + (y + 0.5 - points[i][1]) ** 2)
            px, py, width, distance = points[index]
            dx, dy = x + 0.5 - px, y + 0.5 - py
            offset = hypot(dx, dy)
            if offset > width:
                continue
            previous = points[max(0, index - 1)]
            following = points[min(len(points) - 1, index + 1)]
            tx, ty = following[0] - previous[0], following[1] - previous[1]
            tangent_length = hypot(tx, ty)
            across = (-ty * dx + tx * dy) / tangent_length
            light = (-dx - dy) / (max(offset, 0.5) * 1.414)
            edge = offset > width - 0.7
            if not edge and -width * 0.40 <= across <= width * 0.63:
                # Чистый зелёный канал сохраняет независимую перекраску брюшка.
                value = 210
                if int(distance / 3.5) % 3 == 0:
                    value = 180
                if light > 0.5:
                    value = min(230, value + 20)
                image.putpixel((x, y), (0, value, 0, 255))
            else:
                # Чистый красный канал сохраняет независимую перекраску чешуи.
                value = (170 if edge else 210) + round(light * 20 / 10) * 10
                image.putpixel((x, y), (max(150, min(240, value)), 0, 0, 255))
    return image


def checkerboard(size):
    image = Image.new('RGBA', size, (48, 51, 56, 255))
    draw = ImageDraw.Draw(image)
    for y in range(0, size[1], 8):
        for x in range(0, size[0], 8):
            if (x // 8 + y // 8) % 2:
                draw.rectangle((x, y, x + 7, y + 7), fill=(62, 65, 70, 255))
    return image


def main():
    original = Image.open(SOURCE).convert('RGBA')
    base = draw_tail()
    overlay = Image.new('RGBA', (SIZE, SIZE))
    # Берём срез из текущего DMI без перерисовки и переносим к новому основанию.
    original_cut = original.crop((SIZE, 0, SIZE * 2, SIZE))
    cut = original_cut.crop(original_cut.getbbox())
    overlay.alpha_composite(cut, (20, 5))
    combined = Image.alpha_composite(base, overlay)

    sheet = Image.new('RGBA', (SIZE * 2, SIZE))
    sheet.paste(base, (0, 0))
    sheet.paste(overlay, (SIZE, 0))
    description = '\n'.join([
        '# BEGIN DMI', 'version = 4.0', '\twidth = 32', '\theight = 32',
        'state = "naga_tail"', '\tdirs = 1', '\tframes = 1',
        'state = "naga_tail_cut"', '\tdirs = 1', '\tframes = 1', '# END DMI', '',
    ])
    metadata = PngImagePlugin.PngInfo()
    metadata.add_text('Description', description, zip=True)
    sheet.save(OUTPUT / 'naga_tail_spiral_v2.dmi', format='PNG', pnginfo=metadata)
    for name, image in [('base', base), ('overlay', overlay), ('combined', combined)]:
        image.save(OUTPUT / f'{name}.png')

    scale = 12
    tile_size = SIZE * scale
    panel = Image.new('RGB', (tile_size * 3 + 64, tile_size + 76), (32, 35, 40))
    draw = ImageDraw.Draw(panel)
    font = ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf', 20)
    for column, (title, image) in enumerate([('Основа · 32×32', base), ('Оверлей среза · 32×32', overlay), ('Вместе · увеличение ×12', combined)]):
        left = 16 + column * (tile_size + 16)
        draw.text((left, 15), title, font=font, fill=(224, 227, 232))
        tile = checkerboard((SIZE, SIZE))
        tile.alpha_composite(image)
        panel.paste(tile.resize((tile_size, tile_size), Image.Resampling.NEAREST), (left, 52))
    panel.save(OUTPUT / 'preview.png')

    # Проверяем размер кадров, имена состояний и отсутствие полупрозрачных пикселей.
    with Image.open(OUTPUT / 'naga_tail_spiral_v2.dmi') as saved:
        assert saved.size == (64, 32)
        assert saved.info['Description'] == description
        assert set(saved.getchannel('A').get_flattened_data()) <= {0, 255}
    assert base.getbbox() and overlay.getbbox()
    print(OUTPUT / 'naga_tail_spiral_v2.dmi')
    print(OUTPUT / 'preview.png')


if __name__ == '__main__':
    main()
