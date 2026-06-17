import io
import json
import re
from pathlib import Path

import requests
from PIL import Image, ImageDraw, ImageFont

BASE_DIR = Path(__file__).resolve().parent
LOGOS_DIR = BASE_DIR / "logos"
CANALES_JSON = BASE_DIR / "canales.json"

RAW_BASE_URL = "https://raw.githubusercontent.com/LiderSalinas/tv-paraguay-data/main/logos"

LOGOS_DIR.mkdir(exist_ok=True)

HEADERS = {
    "User-Agent": "Mozilla/5.0"
}

CHANNEL_LOGOS = [
    {
        "id": 1,
        "name": "PARAGUAY TV",
        "shortName": "PYTV",
        "filename": "paraguay-tv.png",
        "urls": [
            "https://upload.wikimedia.org/wikipedia/commons/1/10/Paraguay_TV_logo.png",
            "https://www.google.com/s2/favicons?domain=https://www.paraguaytv.gov.py&sz=256",
        ],
    },
    {
        "id": 2,
        "name": "TELEFUTURO",
        "shortName": "TF",
        "filename": "telefuturo.png",
        "urls": [
            "https://upload.wikimedia.org/wikipedia/commons/4/49/Telefuturo2017.png",
            "https://www.google.com/s2/favicons?domain=https://www.telefuturo.com.py&sz=256",
        ],
    },
    {
        "id": 3,
        "name": "SNT",
        "shortName": "SNT",
        "filename": "snt.png",
        "urls": [
            "https://directostv.teleame.com/wp-content/uploads/2017/10/SNT-Paraguay-en-vivo-Online.png",
            "https://www.google.com/s2/favicons?domain=https://www.snt.com.py&sz=256",
        ],
    },
    {
        "id": 4,
        "name": "NPY",
        "shortName": "NPY",
        "filename": "npy.png",
        "urls": [
            "https://upload.wikimedia.org/wikipedia/commons/6/60/NPY_%28Noticias_Paraguay%29.png",
            "https://www.google.com/s2/favicons?domain=https://www.npy.com.py&sz=256",
        ],
    },
    {
        "id": 5,
        "name": "C9N",
        "shortName": "C9N",
        "filename": "c9n.png",
        "urls": [
            "https://www.c9n.com.py/wp-content/uploads/2020/11/330x330_logo_grande_C9N.png",
            "https://www.google.com/s2/favicons?domain=https://www.c9n.com.py&sz=256",
        ],
    },
    {
        "id": 6,
        "name": "COSMOS TV",
        "shortName": "COSMOS",
        "filename": "cosmos-tv.png",
        "urls": [
            "https://www.google.com/s2/favicons?domain=https://cosmosmultimedios.com.py&sz=256",
            "https://www.google.com/s2/favicons?domain=https://radios.com.py/tv/cosmos&sz=256",
        ],
    },
    {
        "id": 7,
        "name": "MEGA TV",
        "shortName": "MEGA",
        "filename": "mega-tv.png",
        "urls": [
            "https://www.google.com/s2/favicons?domain=https://megacadena.com.py&sz=256",
        ],
    },
    {
        "id": 8,
        "name": "CANAL PRO",
        "shortName": "PRO",
        "filename": "canal-pro.png",
        "urls": [
            "https://www.google.com/s2/favicons?domain=https://megacadena.com.py&sz=256",
        ],
    },
    {
        "id": 9,
        "name": "ÑANDUTI TV",
        "shortName": "ÑTV",
        "filename": "nanduti-tv.png",
        "urls": [
            "https://www.google.com/s2/favicons?domain=https://www.nanduti.com.py&sz=256",
            "https://i.postimg.cc/y8NmrWvJ/anduti-tv.png",
        ],
    },
    {
        "id": 10,
        "name": "REPUBLICA TV",
        "shortName": "REP",
        "filename": "republica-tv.png",
        "urls": [
            "https://www.google.com/s2/favicons?domain=https://www.republicafmtv.com.py&sz=256",
            "https://www.google.com/s2/favicons?domain=https://www.republicaradiotv.com.py&sz=256",
        ],
    },
    {
        "id": 11,
        "name": "MONUMENTAL TV",
        "shortName": "MON",
        "filename": "monumental-tv.png",
        "urls": [
            "https://www.google.com/s2/favicons?domain=https://www.monumental.com.py&sz=256",
        ],
    },
    {
        "id": 12,
        "name": "BRUNO MASI TV",
        "shortName": "BM",
        "filename": "bruno-masi-tv.png",
        "urls": [
            "https://www.google.com/s2/favicons?domain=https://www.brunomasi.com.py&sz=256",
        ],
    },
    {
        "id": 13,
        "name": "TRECE",
        "shortName": "13",
        "filename": "trece.png",
        "urls": [
            "http://www.trece.com.py/public/img/Logo-Trece.png",
            "https://www.google.com/s2/favicons?domain=https://www.trece.com.py&sz=256",
        ],
    },
    {
        "id": 14,
        "name": "UNICANAL",
        "shortName": "UNI",
        "filename": "unicanal.png",
        "urls": [
            "http://www.unicanal.com.py/public/img/LogoUnicanalBlanco.png",
            "https://www.google.com/s2/favicons?domain=https://www.unicanal.com.py&sz=256",
        ],
    },
    {
        "id": 15,
        "name": "GEN TV",
        "shortName": "GEN",
        "filename": "gen-tv.png",
        "urls": [
            "https://www.google.com/s2/favicons?domain=https://www.gen.com.py&sz=256",
        ],
    },
    {
        "id": 16,
        "name": "ABC DIGITAL",
        "shortName": "ABC",
        "filename": "abc-digital.png",
        "urls": [
            "https://www.google.com/s2/favicons?domain=https://www.abc.com.py&sz=256",
            "https://directostv.teleame.com/wp-content/uploads/2019/11/ABC-TV-Paraguay-en-vivo-Online.png",
        ],
    },
    {
        "id": 17,
        "name": "LATELE",
        "shortName": "LT",
        "filename": "latele.png",
        "urls": [
            "https://latele.com.py/wp-content/themes/lateleads/img/logo-latele-blanco.png",
            "https://www.google.com/s2/favicons?domain=https://latele.com.py&sz=256",
        ],
    },
    {
        "id": 18,
        "name": "ASPEN TV",
        "shortName": "ASPEN",
        "filename": "aspen-tv.png",
        "urls": [
            "https://www.google.com/s2/favicons?domain=https://www.radioaspen.com.py&sz=256",
        ],
    },
    {
        "id": 19,
        "name": "ESTACION 40 TV",
        "shortName": "E40",
        "filename": "estacion-40-tv.png",
        "urls": [
            "https://www.google.com/s2/favicons?domain=https://estacion40.com.py&sz=256",
            "https://www.google.com/s2/favicons?domain=https://e40.com.py&sz=256",
        ],
    },
    {
        "id": 20,
        "name": "VENUS MEDIA",
        "shortName": "VENUS",
        "filename": "venus-media.png",
        "urls": [
            "https://www.google.com/s2/favicons?domain=https://venus.com.py&sz=256",
        ],
    },
]


def download_image(url: str):
    try:
        response = requests.get(url, headers=HEADERS, timeout=25)
        if response.status_code != 200:
            return None

        content_type = response.headers.get("Content-Type", "").lower()
        if "image" not in content_type and not url.lower().endswith((".png", ".jpg", ".jpeg", ".webp", ".ico")):
            return None

        return Image.open(io.BytesIO(response.content)).convert("RGBA")
    except Exception:
        return None


def fit_logo(img: Image.Image, size=(256, 256), padding=18):
    canvas = Image.new("RGBA", size, (0, 0, 0, 0))

    max_w = size[0] - padding * 2
    max_h = size[1] - padding * 2

    width, height = img.size
    if width <= 0 or height <= 0:
        return canvas

    scale = min(max_w / width, max_h / height)
    new_w = max(1, int(width * scale))
    new_h = max(1, int(height * scale))

    resized = img.resize((new_w, new_h), Image.LANCZOS)

    x = (size[0] - new_w) // 2
    y = (size[1] - new_h) // 2

    canvas.paste(resized, (x, y), resized)
    return canvas


def create_placeholder(short_name: str, size=(256, 256)):
    background = (22, 22, 28, 255)
    border = (75, 75, 90, 255)
    text_color = (255, 255, 255, 255)

    img = Image.new("RGBA", size, background)
    draw = ImageDraw.Draw(img)

    draw.rounded_rectangle(
        [(8, 8), (size[0] - 8, size[1] - 8)],
        radius=30,
        fill=background,
        outline=border,
        width=4,
    )

    label = short_name.strip()[:6].upper()

    try:
        font = ImageFont.truetype("arial.ttf", 70)
    except Exception:
        font = ImageFont.load_default()

    bbox = draw.textbbox((0, 0), label, font=font)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]

    x = (size[0] - text_w) // 2
    y = (size[1] - text_h) // 2 - 4

    draw.text((x, y), label, font=font, fill=text_color)
    return img


def save_logo(channel):
    filename = channel["filename"]
    output_path = LOGOS_DIR / filename

    image = None

    print(f"\n[{channel['id']}] {channel['name']}")

    for url in channel["urls"]:
        print(f"  probando: {url}")
        image = download_image(url)

        if image is not None:
            print("  logo encontrado")
            break

    if image is None:
        print("  no se pudo descargar logo, creando placeholder")
        image = create_placeholder(channel["shortName"])

    final_logo = fit_logo(image)
    final_logo.save(output_path, "PNG", optimize=True)

    print(f"  guardado: logos/{filename}")


def update_canales_json():
    if not CANALES_JSON.exists():
        print("\nNo encontré canales.json en esta carpeta.")
        print("Este script debe estar en la misma carpeta que canales.json.")
        return

    with open(CANALES_JSON, "r", encoding="utf-8") as file:
        channels = json.load(file)

    logo_by_id = {
        item["id"]: item["filename"]
        for item in CHANNEL_LOGOS
    }

    for channel in channels:
        channel_id = channel.get("id")
        filename = logo_by_id.get(channel_id)

        if filename:
            channel["logoUrl"] = f"{RAW_BASE_URL}/{filename}"

    with open(CANALES_JSON, "w", encoding="utf-8") as file:
        json.dump(channels, file, ensure_ascii=False, indent=2)

    print("\ncanales.json actualizado con logoUrl.")


def main():
    print("Iniciando descarga y normalización de logos...")
    print(f"Carpeta base: {BASE_DIR}")
    print(f"Carpeta logos: {LOGOS_DIR}")

    for channel in CHANNEL_LOGOS:
        save_logo(channel)

    update_canales_json()

    print("\nLISTO.")
    print("Ahora revisá la carpeta logos y el archivo canales.json.")


if __name__ == "__main__":
    main()
