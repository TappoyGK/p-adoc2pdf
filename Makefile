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

PDF_BASE_CMD := bundle exec asciidoctor-pdf \
	-a scripts=cjk \
	-a allow-uri-read \
	-a pdf-fontsdir=$(FONT_DIR) \
	-r asciidoctor-diagram

# phony ターゲット
.PHONY: build clean install sample clean-sample

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
	@prefix=$$(echo $* | sed -E 's/^([a-z]+).*/\1/'); \
	theme=resources/themes/$$prefix-theme.yml; \
	[ -f $$theme ] || theme=resources/themes/basic-theme.yml; \
	$(PDF_BASE_CMD) -a pdf-theme=$$theme $<
	@mv $(basename $<).pdf $@

# クリーンアップ
clean:
	@echo "[INFO] 生成物を削除します"
	@rm -f $(TARGETS) $(SOURCES:src/%.adoc=%.pdf)

# sample ターゲット (example build for sample_src → sample_dst)
sample_src_dir := sample_src
sample_dst_dir := sample_dst
SAMPLE_SOURCES := $(wildcard $(sample_src_dir)/*.adoc)
SAMPLE_TARGETS := $(SAMPLE_SOURCES:$(sample_src_dir)/%.adoc=$(sample_dst_dir)/%.pdf)

sample: install $(SAMPLE_TARGETS)

# ルール: sample_dst_dir が無ければ作成
$(sample_dst_dir):
	@mkdir -p $@

# ルール: src → pdf
$(sample_dst_dir)/%.pdf: $(sample_src_dir)/%.adoc resources/themes/basic-theme.yml | $(sample_dst_dir)
	@echo "[SAMPLE] PDF を生成します: $@"
	@prefix=$$(echo $* | sed -E 's/^([a-z]+).*/\1/'); \
	theme=resources/themes/$$prefix-theme.yml; \
	[ -f $$theme ] || theme=resources/themes/basic-theme.yml; \
	$(PDF_BASE_CMD) -a pdf-theme=$$theme $<
	@mv $(basename $<).pdf $@

# sample 用生成物削除
clean-sample:
	@echo "[INFO] sample 生成物を削除します"
	@rm -f $(SAMPLE_TARGETS)