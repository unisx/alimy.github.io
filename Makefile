RM= rm -rf

comment ?= update content
cache_path := /tmp/hugo/github.com/alimy
site_path := master
file_list := .files
site_file_list := $(site_path)/.files
master_git_dir := $(PWD)/master/.git
master_work_tree := $(PWD)/master
master_git_flag := --git-dir=$(master_git_dir) --work-tree=$(master_work_tree)

Clean_Site_Files = cat $(file_list) | xargs $(RM) && $(RM) $(file_list)
Clean_Site = [ -s $(site_file_list) ] && $(Do_Clean_Site) || true
Install_Site = cp -r $(cache_path)/* $(site_path)
Update_Site_File_List = ls $(cache_path) | xargs > $(site_file_list)
Hugo_Generate_Site = hugo --destination $(cache_path)
Do_Clean_Site = cd $(site_path);$(Clean_Site_Files);cd ../
Commit_Branch_Hugo = $(Commit_All)
Push_Branch_Hugo = git push
Push_Branch_Master = git $(master_git_flag) push

define Commit_Branch_Hugo
	git add --all .
	-git commit -m "$(comment)"
endef

define Commit_Branch_Master
	cd $(site_path);git $(master_git_flag) add --all .
	-git $(master_git_flag) commit -m "$(comment)"
	cd ../
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

