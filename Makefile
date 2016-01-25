RM= rm -rf

comment ?= update content
cache_path := /tmp/hugo/github.com/alimy
site_path := master
file_list := .files
site_file_list := $(site_path)/.files

Clean_Site_Files = cat $(file_list) | xargs $(RM) && $(RM) $(file_list)
Clean_Site = [ -s $(site_file_list) ] && $(Do_Clean_Site) || true
Install_Site = cp -r $(cache_path)/* $(site_path)
Update_Site_File_List = ls $(cache_path) | xargs > $(site_file_list)
Push_Branch_Hugo = git push
Hugo_Generate_Site = hugo --destination $(cache_path)

define Do_Clean_Site
	cd $(site_path)
	$(Clean_Site_Files)
	cd $(content_path_relate_site)
endef

define Commit_All
	git --work-tree="$(PWD)" add --all .
	git commit -m "$(comment)"
endef

define Commit_Branch_Hugo
	$(Commit_All) || true
endef

define Commit_Branch_Master
	cd $(site_path)
	$(Commit_All) || true
	cd -
endef

define Push_Branch_Master
	cd $(site_path)
	git push
	cd -
endef

help:
	@echo "  publish	- Publish site to remote"
	@echo "  push		- Push original content and site to remote"
	@echo "  commit	- Commit content and site to corresponding local repository"
	@echo "  generate	- Generate site from content"
	@echo "  serve		- Serve site in live time"
	@echo "  test		- Test site in simulate deploy place"
	@echo "  clean		- Clean site files that used to publish"
	@echo "  distclean	- Clean site files and cache files"

publish: commit
	$(Push_Branch_Master)

push: commit
	$(Push_Branch_Hugo)
	$(Push_Branch_Master)

commit: generate
	$(Commit_Branch_Hugo)
	$(Commit_Branch_Master)

generate: distclean
	$(Hugo_Generate_Site)
	$(Install_Site) && $(Update_Site_File_List)

clean:
	$(Clean_Site)

distclean: clean
	$(RM) $(Cache_Path)

serve:
	hugo serve -w || true

test:
	caddy -root master

.PHONY: help generate publish push commit serve test clean distclean

