all: install-deps build prune install-repo update

install-deps:
	flatpak --user remote-add --if-not-exists --from flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak --user install flathub org.freedesktop.Platform/x86_64/1.6 org.freedesktop.Sdk/x86_64/1.6 || true

build:
	flatpak-builder --force-clean --ccache --require-changes --repo=repo \
		--subject="Nightly build of Signal, `date`" \
		${EXPORT_ARGS} app org.signal.Desktop.json

prune:
	flatpak build-update-repo --prune --prune-depth=20 repo

install-repo:
	flatpak --user remote-add --if-not-exists --no-gpg-verify nightly-signal ./repo
	flatpak --user -v install nightly-signal org.signal.Desktop || true

update:
	flatpak update --user org.signal.Desktop
