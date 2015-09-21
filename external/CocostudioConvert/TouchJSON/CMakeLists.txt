aux_source_directory(./Source LIB_SRC)
add_library(TouchJSON ${LIB_SRC})
set(LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/lib)
target_link_libraries(TouchJSON "-framework Cocoa")