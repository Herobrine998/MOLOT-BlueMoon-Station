import importlib.util
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, PngImagePlugin


OUTPUT = Path(__file__).resolve().parent
ROOT = OUTPUT.parents[1]
SPEC = importlib.util.spec_from_file_location('spiral_v4', ROOT / 'output/naga-tail-spiral-v4/draw_spiral.py')
DRAWING = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(DRAWING)
VARIANTS = [
    (5, 'Округлый виток', (7, 0), [
        (11.6, 6, 3.6), (8.4, 10, 3.9), (6.8, 16, 4.0),
        (7.3, 22, 4.2), (11.8, 26, 4.0), (18, 26.7, 3.8),
        (24, 24.1, 3.6), (27, 19, 3.2), (26.2, 13.7, 3.1),
        (22, 10.5, 3.0), (17, 10.5, 2.8), (13.5, 13, 2.8),
        (12.8, 17, 2.8), (15.2, 20.6, 2.6), (19.5, 21.8, 2.4),
        (22.5, 19.8, 2.1), (21.2, 16.8, 1.7), (18.5, 16.3, 1.0),
    ]),
    (6, 'Широкий виток', (6, 0), [
        (11, 5.9, 3.6), (7.8, 11.3, 3.9), (6.7, 18.6, 3.8),
        (8.8, 23.6, 4.1), (14.8, 26.2, 4.1), (22.2, 25.7, 3.7),
        (27, 22, 3.4), (27.3, 17.2, 3.2), (24, 14, 3.0),
        (19, 13.3, 3.0), (14.7, 14.5, 3.0), (13, 18, 2.8),
        (15.5, 20.6, 2.4), (20, 21, 2.0), (21.5, 18.9, 1.7),
        (19.6, 17.2, 1.1),
    ]),
    (7, 'Тугой виток', (8, 0), [
        (13, 5.8, 3.7), (9, 10, 3.8), (6.4, 15.8, 4.1),
        (7, 21.8, 4.3), (11, 25.7, 4.0), (17.5, 26.7, 3.8),
        (24, 24.5, 3.5), (27, 19.5, 3.2), (26, 14, 3.0),
        (22, 10.9, 2.8), (17, 11.1, 2.8), (13.5, 14.1, 2.8),
        (13.6, 18.1, 2.6), (16.9, 21, 2.3), (21, 20.3, 2.0),
        (22.3, 17.5, 1.8), (20.3, 15, 1.5), (17.5, 15.2, 1.2),
        (16.8, 17.3, .9), (18.4, 18.2, .6),
    ]),
]


def panel(images):
    result = Image.new('RGB', (1216, 460), (32, 35, 40))
    draw = ImageDraw.Draw(result)
    font = ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf', 20)
    for column, (title, image) in enumerate(images):
        left = 16 + column * 400
        draw.text((left, 15), title, font=font, fill=(224, 227, 232))
        background = Image.new('RGBA', (32, 32), (48, 51, 56, 255))
        checker = ImageDraw.Draw(background)
        for y in range(0, 32, 4):
            for x in range(0, 32, 4):
                if (x // 4 + y // 4) % 2:
                    checker.rectangle((x, y, x+3, y+3), fill=(62, 65, 70, 255))
        background.alpha_composite(image)
        result.paste(background.resize((384, 384), Image.Resampling.NEAREST), (left, 52))
    return result


def main():
    original = Image.open(ROOT / 'icons/obj/naga_tail_item.dmi').convert('RGBA')
    original_cut = original.crop((32, 0, 64, 32))
    cut = original_cut.crop(original_cut.getbbox())
    description = Image.open(ROOT / 'output/naga-tail-spiral-v4/naga_tail_spiral_v4.dmi').info['Description']
    metadata = PngImagePlugin.PngInfo()
    metadata.add_text('Description', description, zip=True)
    comparison = []
    for index, (version, title, cut_position, anchors) in enumerate(VARIANTS, 1):
        DRAWING.ANCHORS = anchors
        base = DRAWING.draw_tail()
        overlay = Image.new('RGBA', (32, 32))
        overlay.alpha_composite(cut, cut_position)
        combined = Image.alpha_composite(base, overlay)
        destination = ROOT / f'output/naga-tail-spiral-v{version}'
        destination.mkdir(exist_ok=True)
        sheet = Image.new('RGBA', (64, 32))
        sheet.paste(base, (0, 0))
        sheet.paste(overlay, (32, 0))
        dmi = destination / f'naga_tail_spiral_v{version}.dmi'
        sheet.save(dmi, format='PNG', pnginfo=metadata)
        for name, image in [('base', base), ('overlay', overlay), ('combined', combined)]:
            image.save(destination / f'{name}.png')
        panel([('Основа · 32×32', base), ('Оверлей среза · 32×32', overlay), ('Вместе · увеличение ×12', combined)]).save(destination / 'preview.png')
        with Image.open(dmi) as saved:
            assert saved.size == (64, 32)
            assert saved.info['Description'] == description
            assert set(saved.getchannel('A').get_flattened_data()) == {0, 255}
        assert combined.getbbox() == (0, 0, 32, 32)
        assert 0 not in DRAWING.outside_mask(base).get_flattened_data()
        assert all(not alpha or (red == 0 and blue == 0) or (green == 0 and blue == 0) for red, green, blue, alpha in base.get_flattened_data())
        comparison.append((f'{index}. {title}', combined))
        print(dmi)
    panel(comparison).save(OUTPUT / 'comparison.png')
    print(OUTPUT / 'comparison.png')


if __name__ == '__main__':
    main()
