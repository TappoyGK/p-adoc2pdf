# デフォルトターゲット
.DEFAULT_GOAL := build

# 変数定義
SOURCES := $(wildcard src/*.adoc)
TARGETS := $(SOURCES:src/%.adoc=dst/%.pdf)
FONT_DIR := resources/fonts
# KaiGen Gothic JP フォントのみ使用
FONT_NAMES := \
	KaiGenGothicJP-Regular.ttf \
	KaiGenGothicJP-Bold.ttf \
	KaiGenGothicJP-Regular-Italic.ttf \
	KaiGenGothicJP-Bold-Italic.ttf
FONTS := $(addprefix $(FONT_DIR)/,$(FONT_NAMES))
FONT_URL_BASE := https://github.com/chloerei/asciidoctor-pdf-cjk-kai_gen_gothic/releases/download/v0.1.0-fonts

PDF_CMD := bundle exec asciidoctor-pdf \
	-a scripts=cjk \
	-a pdf-theme=resources/themes/basic-theme.yml \
	-a pdf-fontsdir=$(FONT_DIR) \
	-r asciidoctor-diagram

# phony ターゲット
.PHONY: build clean install

# install ターゲット（フォントを取得）
install: $(FONTS)

# フォントをダウンロードするルール
$(FONT_DIR)/%.ttf:
	@echo "[INFO] ダウンロード: $(@F)"
	@mkdir -p $(FONT_DIR)
	@curl -L -o $@ $(FONT_URL_BASE)/$(@F)

# build ターゲット
build: install $(TARGETS)

# PDF 生成ルール
dst/%.pdf: src/%.adoc resources/themes/basic-theme.yml
	@echo "[INFO] PDF を生成します: $@"
	@mkdir -p $(dir $@)
	@$(PDF_CMD) $<
	@mv $(basename $<).pdf $@

# クリーンアップ
clean:
	@echo "[INFO] 生成物を削除します"
	@rm -f $(TARGETS) $(SOURCES:src/%.adoc=%.pdf) 