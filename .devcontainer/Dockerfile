# LaTeX dev container with Overleaf-like stability (pinned TeX Live)
# Use a valid tag; 2025 does not exist on this image. Pin via tlmgr instead.
ARG TL_YEAR=latest
FROM ghcr.io/xu-cheng/texlive-full:${TL_YEAR}

# Dated CTAN archive snapshot (YYYY/MM/DD) for reproducible builds
ARG SNAPSHOT_DATE=2025/09/01

# Noninteractive apt
ENV DEBIAN_FRONTEND=noninteractive

# Minimal OS deps
RUN apt-get update && apt-get install -y --no-install-recommends \
  tini locales ca-certificates \
  perl libyaml-tiny-perl libfile-homedir-perl libunicode-linebreak-perl \
  python3 python3-pip \
  ghostscript \
  && rm -rf /var/lib/apt/lists/*

# Minted support
RUN pip3 install --no-cache-dir pygments

# UTF-8 locale
RUN sed -i 's/# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Freeze tlmgr to dated snapshot and update once
RUN tlmgr option repository https://ctan.math.utah.edu/ctan/tex-archive/systems/texlive/tlnet-archive/${SNAPSHOT_DATE}/tlnet \
  && tlmgr update --self --all

# Sanity checks (non-fatal)
RUN latexmk -v && biber -v || true && latexindent -v || true

# Non-root user
ARG USERNAME=latex
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} ${USERNAME} && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USERNAME}
USER ${USERNAME}

# Workspace
WORKDIR /workdir

# Entrypoint
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash"]

