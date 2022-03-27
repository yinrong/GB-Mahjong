CXX			:= g++

RM			:= rm -f
MKDIR		:= mkdir -p
RMDIR		:= rmdir
SED			:= sed

CXXFLAGS    := -std=gnu++0x -O0 -DBOOST_STACKTRACE_USE_ADDR2LINE -g -fPIC 
CXXDFLAGS   := -libl
LDFLAGS		:= 

BUILDDIR	:= ./build
OBJDIR		:= $(BUILDDIR)/obj
BINDIR		:= $(BUILDDIR)/bin

VPATH		:= console:mahjong

py = /home/yinrong/.sw/conda/envs/torch/bin
CXXINCLUDE := $(patsubst %,-I%,$(subst :, ,$(VPATH))) \
              $(shell $(py)/python -m pybind11 --includes)

Dirs		:= $(OBJDIR) $(BINDIR)

Example		:= $(BINDIR)/example
Pylib := $(BINDIR)/mj.cpython-39-x86_64-linux-gnu.so
Check		:= $(BINDIR)/unit_test

Objects		:= $(patsubst %.cpp, $(OBJDIR)/%.o, $(notdir $(wildcard *.cpp */*.cpp)))


all: $(Example) $(Pylib) $(Check)

$(OBJDIR)/%.o: %.cpp | $(Dirs)
	$(CXX) $(CXXFLAGS) $(CXXINCLUDE) -c $< -o $@

$(OBJDIR)/%.d: %.cpp | $(Dirs)
	@set -e; $(RM) $@; \
	$(CXX) $(CXXFLAGS) $(CXXINCLUDE) -MM $< > $@.$$$$; \
	$(SED) -i 's,\($*\)\.o[ :]*,\1.o $@ : ,g' $@.$$$$; \
	$(SED) '1s/^/$(subst /,\/,$(OBJDIR))\//' < $@.$$$$ > $@; \
	$(RM) $@.$$$$

ifneq ($(MAKECMDGOALS),clean)
-include $(Objects:.o=.d)
endif

obj_example = $(OBJDIR)/$(subst $(BINDIR)/,,$(Example).o)
obj_pyext = $(OBJDIR)/$(subst $(BINDIR)/,,pyext.o)
obj_check = $(OBJDIR)/$(subst $(BINDIR)/,,$(Check).o)
$(Example):	$(filter-out $(obj_pyext) $(obj_check),$(Objects))
	$(CXX) $(CXXFLAGS) $(CXXINCLUDE) -o $@ $^ $(LDFLAGS)

$(Check):	$(filter-out $(obj_pyext) $(obj_example), $(Objects))
	$(CXX) $(CXXFLAGS) $(CXXINCLUDE) -o $@ $^ $(LDFLAGS)
$(Pylib):	$(filter-out $(obj_example) $(obj_check), $(Objects))
	$(CXX) $(CXXFLAGS) $(CXXINCLUDE) -shared -o $@ $^ $(LDFLAGS)
$(Dirs):
	$(MKDIR) $@

debug: CXXFLAGS := $(CXXDFLAGS)
debug: $(Example) $(Check) $(Pylib)

run: $(Example)
	$(Example)

check: $(Check)
	$(Check)

clean:
	rm -rf $(BUILDDIR)

.PHONY: all debug run check clean
