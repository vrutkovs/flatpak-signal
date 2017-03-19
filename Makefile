all: install-deps build prune install-repo
	flatpak update --user org.signal.Desktop

install-deps:
	flatpak --user remote-add --if-not-exists --from gnome-nightly https://sdk.gnome.org/gnome.flatpakrepo
	flatpak --user install gnome-nightly org.freedesktop.Platform/x86_64/1.6 org.freedesktop.Sdk/x86_64/1.6 || true

build-electron-base:
	cd electron-flatpak-base-app;\
	make;\
    flatpak build-update-repo --prune --prune-depth=20 ./repo;\
    flatpak --user remote-add --no-gpg-verify local-electron ./repo || true;\
    flatpak --user -v install local-electron io.atom.electron.BaseApp || true;\
    flatpak update --user io.atom.electron.BaseApp;\
    cd ..

build: build-electron-base
	flatpak-builder --force-clean --ccache --require-changes --repo=repo \
		--subject="Nightly build of Signal, `date`" \
		${EXPORT_ARGS} app org.signal.Desktop.json

prune:
	flatpak build-update-repo --prune --prune-depth=20 repo

install-repo:
	flatpak --user remote-add --if-not-exists --no-gpg-verify nightly-signal ./repo
	flatpak --user -v install nightly-signal org.signal.Desktop || true
