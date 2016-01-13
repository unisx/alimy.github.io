RM= rm -rf
Cache_Path= "/tmp/hugo/github.com/alimy"
Site_Path= "master"
File_List=".files"
Site_File_List= $(Site_Path)/.files
Clean_Site_Files= cat $(File_List) | xargs $(RM) && $(RM) $(File_List)
Do_Clean_Site= cd $(Site_Path) && $(Clean_Site_Files) && cd ../
Clean_Site= [ -s $(Site_File_List) ] && $(Do_Clean_Site) || true
Install_Site= cp -r $(Cache_Path)/* $(Site_Path)
Update_Site_File_List= ls $(Cache_Path) | xargs > $(Site_File_List)

all: gen

gen: distclean
	hugo --destination $(Cache_Path)
	$(Install_Site) && $(Update_Site_File_List) 

clean:
	$(Clean_Site)

distclean: clean
	$(RM) $(Cache_Path)

serve:
	hugo serve -w || true

test:
	caddy -root master

.PHONY: all gen serve test clean distclean

