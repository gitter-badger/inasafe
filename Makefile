#/***************************************************************************
# Riab
#
# Disaster risk assessment tool developed by AusAid and World Bank
#                             -------------------
#        begin                : 2012-01-09
#        copyright            : (C) 2012 by Australia Indonesia Facility for Disaster Reduction
#        email                : ole.moller.nielsen@gmail.com
# ***************************************************************************/
#
#/***************************************************************************
# *                                                                         *
# *   This program is free software; you can redistribute it and/or modify  *
# *   it under the terms of the GNU General Public License as published by  *
# *   the Free Software Foundation; either version 2 of the License, or     *
# *   (at your option) any later version.                                   *
# *                                                                         *
# ***************************************************************************/

# Makefile for a PyQGIS plugin

PLUGINNAME = riab

PY_FILES = riab.py riabdock.py riabhelp.py __init__.py

EXTRAS = icon.png

UI_FILES = ui_riabdock.py ui_riabhelp.py

RESOURCE_FILES = resources.py

default: compile

compile: $(UI_FILES) $(RESOURCE_FILES)

%.py : %.qrc
	pyrcc4 -o $@  $<
	#this is ugly but the resource referenced by the ui
	#looks for a file generated with a different name
	cp resources.py resources_rc.py

%.py : %.ui
	pyuic4 -o $@ $<


# The deploy  target only works on unix like operating system where
# the Python plugin directory is located at:
# $HOME/.qgis/python/plugins
deploy: compile
	mkdir -p $(HOME)/.qgis/python/plugins/$(PLUGINNAME)
	cp -vf $(PY_FILES) $(HOME)/.qgis/python/plugins/$(PLUGINNAME)
	cp -vf $(UI_FILES) $(HOME)/.qgis/python/plugins/$(PLUGINNAME)
	cp -vf $(RESOURCE_FILES) $(HOME)/.qgis/python/plugins/$(PLUGINNAME)
	cp -vf $(EXTRAS) $(HOME)/.qgis/python/plugins/$(PLUGINNAME)

# Create a zip package of the plugin named $(PLUGINNAME).zip.
# This requires use of git (your plugin development directory must be a
# git repository).
# To use, pass a valid commit or tag as follows:
#   make package VERSION=Version_0.3.2
package: compile
		rm -f $(PLUGINNAME).zip
		git archive --prefix=$(PLUGINNAME)/ -o $(PLUGINNAME).zip $(VERSION)
		echo "Created package: $(PLUGINNAME).zip"

docs: compile
	cd docs; make html; cd ..

# Run the test suite followed by pep8 style checking
test: test_suite pep8

# Run pep8 style checking only
pep8: compile
	@echo
	@echo "-----------"
	@echo "PEP8 issues"
	@echo "-----------"
	pep8 --repeat --ignore=E203 --exclude ui_riab.py,ui_riabdock.py,resources.py,resources_rc.py,ui_riabhelp.py .

# Run test suite only
test_suite: compile
	@echo "----------------------"
	@echo "Regresssion Test Suite"
	@echo "----------------------"

	@# Preceding dash means that make will continue in case of errors
	-nosetests -v --with-id --with-coverage --cover-package=.,engine,storage,impact_functions


