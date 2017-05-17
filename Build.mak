SRC := .

base_version=v2.070.2
compiler=dmd/src/dmd
runtime=druntime/generated/linux/release/64/libdruntime.a druntime/generated/linux/debug/64/libdruntime.a

$(compiler):
	rm -rf dmd
	git clone --branch $(base_version) https://github.com/dlang/dmd.git --depth 1
	cd dmd; git am ../patches/dmd/* || exit 1
	$(MAKE) -C dmd -f posix.mak MODEL=64 RELEASE=1 AUTO_BOOTSTRAP=1

$(runtime): $(compiler)
	rm -rf druntime
	git clone --branch $(base_version) https://github.com/dlang/druntime.git --depth 1
	cd druntime; git am ../patches/druntime/* || exit 1
	$(MAKE) -C druntime -f posix.mak MODEL=64 BUILD=debug
	$(MAKE) -C druntime -f posix.mak MODEL=64 BUILD=release


# Trying to emulate reasonable makefile doesn't work well with Jenkins workspace
# cache, it results in packages not being rebuilt properly.
# For now let's simply use make as a shell script and .PHONY everything until
# using makd packaging separately becomes feasible.

.PHONY: $(compiler) $(runtime)
all   += $(compiler) $(runtime)
