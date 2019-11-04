# DMD version from which to base the dmd-transtional
DLANG_BASE_VER := v2.078.3

# Generated objects
objs := \
	dmd/generated/linux/release/64/dmd \
	dmd/generated/linux/debug/64/dmd \
	druntime/generated/linux/release/64/libdruntime.a \
	druntime/generated/linux/debug/64/libdruntime.a

# Patches to apply
dmd_patches := $(sort $(wildcard patches/dmd/*.patch))
druntime_patches := $(sort $(wildcard patches/druntime/*.patch))

# Code is not in `src`, so avoid errors
SRC := .

# Function to checkout code ($1 is the project to checkout)
define git_clone
$(RM) -r $1
git clone -c protocol.version=1 --depth 1 --branch "$(DLANG_BASE_VER)" "https://github.com/dlang/$1.git"
git -C $1 am $(addprefix ../,$($(1)_patches))
endef

.PHONY: all
all: $(objs)

# Split the fetching fo the repo and the building so if the building is
# interrupted, the repo doesn't need to be fetched again
dmd/.git/config: $(dmd_patches)
	$(call git_clone,dmd)

dmd/generated/linux/%/64/dmd: dmd/.git/config
	$(MAKE) -C dmd -f posix.mak MODEL=64 RELEASE=1 BUILD=$* AUTO_BOOTSTRAP=1

# In the case of druntime, the splitting of fetching and building makes even
# more sense because then we can do both buildings in parallel with -j
druntime/.git/config: $(drt_patches)
	$(call git_clone,druntime)

druntime/generated/linux/%/64/libdruntime.a: dmd/src/dmd druntime/.git/config
	$(MAKE) -C druntime -f posix.mak MODEL=64 BUILD=$* IMPDIR=import/$*

$O/pkg-dmd-transitional.stamp: dmd.conf $(objs)
