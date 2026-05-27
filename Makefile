.PHONY: snapshot snapshot-commit snapshot-push check

snapshot:
	./scripts/update-repo.sh

snapshot-commit:
	./scripts/update-repo.sh --commit

snapshot-push:
	./scripts/update-repo.sh --commit --push

check:
	bash -n scripts/*.sh
	brew bundle check --no-upgrade --file packages/Brewfile
	plutil -lint config/iterm2/com.googlecode.iterm2.plist
	python3 scripts/validate-jsonc.py config/vscode/User/settings.json config/vscode/User/keybindings.json
