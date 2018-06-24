CPP_SHARED := -std=c++11 -O3 -I src -shared -fPIC 
CPP_OPENSSL_OSX := -L/usr/local/opt/openssl/lib -I/usr/local/opt/openssl/include
CPP_OSX := 
#-stdlib=libc++ -mmacosx-version-min=10.7 -undefined dynamic_lookup $(CPP_OPENSSL_OSX)
THIRD_PATH := /Users/caopo/myroot/third
APP_PATH := cpp

#-Wl,R/opt/mysql/lib
LDFLAGS += -L.\
	#-L/Users/caobo/myroot/third/boost_1_67_0/stage/lib\

	#-L/Users/caobo/myroot/third/uWebSockets\
	#-Wl,R/Users/caobo/myroot/third/uWebSockets

CPPFLAGS += -g -lpthread -std=c++11 -luWS -lssl -lcrypto -lz -luv \
	-DELPP_THREAD_SAFE

CPP_INCLUDE := -I.\
	-I$(THIRD_PATH)/boost_1_67_0/\
	-I$(THIRD_PATH)/uWebSockets/src\
	-I$(THIRD_PATH)/lua-5.3.4/src\
	-Ithird/easyloggingpp\

CPP_SLIB := $(THIRD_PATH)/boost_1_67_0/stage/lib/libboost_system.a\
	$(THIRD_PATH)/boost_1_67_0/stage/lib/libboost_thread.a\
	$(THIRD_PATH)/lua-5.3.4/src/liblua.a\


CPP_DLIB := 
CPP_SRC := $(APP_PATH)/main.cpp\
	$(APP_PATH)/net.cpp\
	$(APP_PATH)/lvm.cpp\
	$(APP_PATH)/app.cpp\
	third/easyloggingpp/easylogging++.cc\
	
	

default:
	make `(uname -s)`
Linux:
	$(CXX) $(CPP_SRC) $(CPP_SLIB) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) $(CPP_INCLUDE) -s -o a.out
Darwin:
	$(CXX) $(CPP_SRC) $(CPP_SLIB) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) $(CPP_OSX) $(CPP_INCLUDE) $(CPP_OPENSSL_OSX) -o a.out

# .PHONY: install
# install:
# 	make install`(uname -s)`
# .PHONY: installLinux
# installLinux:
# 	$(eval PREFIX ?= /usr)
# 	if [ -d "/usr/lib64" ]; then mkdir -p $(PREFIX)/lib64 && cp libuWS.so $(PREFIX)/lib64/; else mkdir -p $(PREFIX)/lib && cp libuWS.so $(PREFIX)/lib/; fi
# 	mkdir -p $(PREFIX)/include/uWS
# 	cp src/*.h $(PREFIX)/include/uWS/
# .PHONY: installDarwin
# installDarwin:
# 	$(eval PREFIX ?= /usr/local)
# 	mkdir -p $(PREFIX)/lib
# 	cp libuWS.dylib $(PREFIX)/lib/
# 	mkdir -p $(PREFIX)/include/uWS
# 	cp src/*.h $(PREFIX)/include/uWS/
# .PHONY: clean
# clean:
# 	rm -f libuWS.so
# 	rm -f libuWS.dylib
# .PHONY: tests
# tests:
# 	$(CXX) $(CPP_OPENSSL_OSX) -std=c++11 -O3 tests/main.cpp -Isrc -o testsBin -lpthread -L. -luWS -lssl -lcrypto -lz -luv
