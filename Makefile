variant?=apple
version=3.0-ee
all: dist
	@echo building $(version)  variant $(variant)
	touch dist/$(version)-$(variant)

dist: 
	mkdir -p $@

ci: all
