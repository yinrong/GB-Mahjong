CXX			:= g++

RM			:= rm -f
MKDIR		:= mkdir -p
RMDIR		:= rmdir
SED			:= sed

CXXFLAGS    := -std=gnu++0x -O0 -DBOOST_STACKTRACE_USE_ADDR2LINE -g -fPIC 
CXXDFLAGS   := -libl
LDFLAGS		:= -L/home/yinrong/.opt/conda/envs/3.10/lib -lcrypt -lpthread -ldl -lutil -lm -lpython3.10

BUILDDIR	:= ./build
OBJDIR		:= $(BUILDDIR)/obj
BINDIR		:= $(BUILDDIR)/bin

VPATH		:= console:mahjong

py = /home/yinrong/.opt/conda/envs/3.10/bin
CXXINCLUDE := $(patsubst %,-I%,$(subst :, ,$(VPATH))) \
              $(shell $(py)/python -m pybind11 --includes) \
              -I/home/yinrong/.opt/conda/envs/3.10/include

Dirs		:= $(OBJDIR) $(BINDIR)

Example		:= $(BINDIR)/example
Pylib := $(BINDIR)/mj.so
StaticLib := $(BINDIR)/libmj.a
Check		:= $(BINDIR)/unit_test

Objects		:= $(patsubst %.cpp, $(OBJDIR)/%.o, $(notdir $(wildcard *.cpp */*.cpp)))

all: $(Example) $(Check) $(Pylib)

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
	$(CXX) -shared $(CXXFLAGS) $(CXXINCLUDE) -o $@ $^ $(LDFLAGS) -static-libgcc -static-libstdc++

$(StaticLib): $(filter-out $(obj_example) $(obj_check), $(Objects))
	@echo "Static library generation is disabled."

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
