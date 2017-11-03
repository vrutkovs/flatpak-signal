all: prepare-repo install-deps build update-repo

prepare-repo:
	[[ -d repo ]] || ostree init --mode=archive-z2 --repo=repo
	[[ -d repo/refs/remotes ]] || mkdir -p repo/refs/remotes && touch repo/refs/remotes/.gitkeep

install-deps:
	flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak --user install flathub org.freedesktop.Platform/x86_64/1.6 org.freedesktop.Sdk/x86_64/1.6
	flatpak --user remote-add --no-gpg-verify --if-not-exists electron https://vrutkovs.github.io/io.atom.electron.BaseApp/electron.flatpakrepo
	flatpak --user install electron io.atom.electron.BaseApp

build:
	flatpak-builder --force-clean --ccache --require-changes --repo=repo \
		--subject="Signal Desktop `date`" \
		${EXPORT_ARGS} app org.signal.Desktop.json

update-repo:
	flatpak build-update-repo --prune --prune-depth=20 --generate-static-deltas repo
	echo 'gpg-verify-summary=false' >> repo/config
