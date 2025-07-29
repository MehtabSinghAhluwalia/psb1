def translate_text(text, target_lang='en'):
    try:
        from googletrans import Translator
        translator = Translator()
        translated = translator.translate(text, dest=target_lang)
        return translated.text
    except Exception as e:
        return text  # fallback to original text if error 