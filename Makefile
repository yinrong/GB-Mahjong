CXX			:= g++

RM			:= rm -f
MKDIR		:= mkdir -p
RMDIR		:= rmdir
SED			:= sed

CXXFLAGS	:= -std=c++11 -g -O3 -fPIC
CXXDFLAGS	:= -std=c++11 -g -Wall
LDFLAGS		:=

BUILDDIR	:= ./build
OBJDIR		:= $(BUILDDIR)/obj
BINDIR		:= $(BUILDDIR)/bin

VPATH		:= console:mahjong

py = /home/yinrong/.sw/conda/envs/torch/bin
CXXINCLUDE := $(patsubst %,-I%,$(subst :, ,$(VPATH))) $(shell $(py)/python -m pybind11 --includes)

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
	cp $@ /home/yinrong/dev2/android-demo-app/ObjectDetection/app/src/main/libs/
$(Dirs):
	$(MKDIR) $@

debug: CXXFLAGS := $(CXXDFLAGS)
debug: $(Example) $(Check) $(Pylib)

run: $(Example)
	$(Example)

check: $(Check)
	$(Check)

clean:
	$(RM) $(OBJDIR)/*.o
	# $(RM) $(OBJDIR)/*.o.*
	$(RM) $(OBJDIR)/*.d
	# $(RM) $(OBJDIR)/*.d.*
	$(RM) $(Example)
	$(RM) $(Check)
	-$(RMDIR) $(OBJDIR)
	-$(RMDIR) $(BINDIR)
	-$(RMDIR) $(BUILDDIR)

.PHONY: all debug run check clean
