PDF := note.pdf
SRC := note.md
PANDOC_CONFIG := template/pandoc.yaml

.PHONY: all clean

all: $(PDF)

$(PDF): $(SRC) $(PANDOC_CONFIG)
	pandoc $(SRC) -d $(PANDOC_CONFIG) -o $(PDF)

clean:
	rm -f $(PDF)
