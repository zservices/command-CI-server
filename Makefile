.PHONY: all install uninstall tags

all:

tags:
	@printf "\e[38;5;208mWarning: required is universal-ctags.\e[0m\n"
	@ctags -e -R --options=$$ZPFX/../zinit.git/share/zsh.ctags --languages=zsh \
	    --pattern-length-limit=250 --maxdepth=1

install:
	@if [ -d "$$ZPFX" ]; then \
	    cp -vf functions/{zcommand,msg} command-server "$$ZPFX/bin"; \
	    printf "\e[38;5;39mInstalled to $$ZPFX/bin\e[0m\n"; \
	elif [ -d ~/bin ]; then \
	    cp -vf functions/{zcommand,msg} command-server ~/bin; \
	    printf "\e[38;5;39mInstalled to ~/bin\e[0m\n"; \
	elif [ -d ~/.local/bin ]; then \
	    cp -vf functions/{zcommand,msg} command-server ~/.local/bin; \
	    printf "\e[38;5;39mInstalled to ~/.local/bin\e[0m\n"; \
	else \
	    printf "\e[38;5;208mNo suitable …/bin directory found.\e[0m\n"; \
	    false; \
	fi

uninstall:
	rm -f "$$ZPFX"/{zcommand,msg,command-server} \
		~/bin/{zcommand,msg,command-server} \
		~/.local/bin/{zcommand,msg,command-server}