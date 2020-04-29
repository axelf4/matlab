all: report.pdf

report.pdf: report.tex
	latexmk $(PREVIEW_CONTINUOUSLY) -f -pdf -pdflatex="pdflatex -synctex=1 -interaction=nonstopmode" -use-make report.tex

clean:
	latexmk -C
