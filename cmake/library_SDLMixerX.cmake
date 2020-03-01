
# Note: You must also include "library_AudioCodecs.cmake" too!

add_library(PGE_SDLMixerX        INTERFACE)
add_library(PGE_SDLMixerX_static INTERFACE)

set(PGE_SHARED_SDLMIXER ON)

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(MIX_DEBUG_SUFFIX "d")
else()
    set(MIX_DEBUG_SUFFIX "")
endif()

if(WIN32)
    set(SDL_MixerX_SO_Lib "${DEPENDENCIES_INSTALL_DIR}/lib/lib${CMAKE_SHARED_LIBRARY_PREFIX}SDL2_mixer_ext${PGE_LIBS_DEBUG_SUFFIX}.dll.a")
    set(SDL2_SO_Lib "${DEPENDENCIES_INSTALL_DIR}/lib/lib${CMAKE_SHARED_LIBRARY_PREFIX}SDL2${PGE_LIBS_DEBUG_SUFFIX}.dll.a")
else()
    set(SDL_MixerX_SO_Lib "${DEPENDENCIES_INSTALL_DIR}/lib/${CMAKE_SHARED_LIBRARY_PREFIX}SDL2_mixer_ext${PGE_LIBS_DEBUG_SUFFIX}${CMAKE_SHARED_LIBRARY_SUFFIX}")
    set(SDL2_SO_Lib "${DEPENDENCIES_INSTALL_DIR}/lib/${CMAKE_SHARED_LIBRARY_PREFIX}SDL2${PGE_LIBS_DEBUG_SUFFIX}${CMAKE_SHARED_LIBRARY_SUFFIX}")
endif()

set(SDL2_main_A_Lib "${DEPENDENCIES_INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}SDL2main${PGE_LIBS_DEBUG_SUFFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}")

if(WIN32)
    set(SDL_MixerX_A_Lib "${DEPENDENCIES_INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}SDL2_mixer_ext-static${PGE_LIBS_DEBUG_SUFFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}")
    set(SDL2_A_Lib "${DEPENDENCIES_INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}SDL2-static${PGE_LIBS_DEBUG_SUFFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}")
else()
    set(SDL_MixerX_A_Lib "${DEPENDENCIES_INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}SDL2_mixer_ext${PGE_LIBS_DEBUG_SUFFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}")
    set(SDL2_A_Lib "${DEPENDENCIES_INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}SDL2${PGE_LIBS_DEBUG_SUFFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}")
endif()

set(MixerX_Deps)

set(SDL2_USE_SYSTEM OFF)

# SDL Mixer X - an audio library, fork of SDL Mixer
ExternalProject_Add(
    SDLMixerX_Local
    PREFIX ${CMAKE_BINARY_DIR}/external/SDLMixerX
    GIT_REPOSITORY https://github.com/WohlSoft/SDL-Mixer-X.git
    CMAKE_ARGS
        "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}"
        "-DCMAKE_INSTALL_PREFIX=${DEPENDENCIES_INSTALL_DIR}"
        "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"
        "-DCMAKE_CONFIGURATION_TYPES=${CMAKE_CONFIGURATION_TYPES}"
        "-DDOWNLOAD_AUDIO_CODECS_DEPENDENCY=ON"
        "-DUSE_SYSTEM_SDL2=${SDL2_USE_SYSTEM}"
        "-DCMAKE_DEBUG_POSTFIX=d"
        "-DSDL_MIXER_X_SHARED=${PGE_SHARED_SDLMIXER}"
        "-DAUDIO_CODECS_SDL2_HG_BRANCH=release-2.0.10"
        "-DAUDIO_CODECS_SDL2_GIT_BRANCH=origin/release-2.0.10"
        "-DWITH_SDL2_WASAPI=OFF"
        ${ANDROID_CMAKE_FLAGS}
        $<$<BOOL:APPLE>:-DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}>
        $<$<BOOL:WIN32>:-DCMAKE_SHARED_LIBRARY_PREFIX="">
    DEPENDS ${MixerX_Deps}
    BUILD_BYPRODUCTS
        "${SDL_MixerX_SO_Lib}"
        "${SDL_MixerX_A_Lib}"
        "${SDL2_SO_Lib}"
        "${SDL2_A_Lib}"
        "${SDL2_main_A_Lib}"
)

set(SDL2_INCLUDE_DIRS ${DEPENDENCIES_INSTALL_DIR}/include/SDL2)
set(SDL2_LIBRARIES ${DEPENDENCIES_INSTALL_DIR}/lib)

target_link_libraries(PGE_SDLMixerX INTERFACE "${SDL_MixerX_SO_Lib}")

if(WIN32 AND MINGW)
    target_link_libraries(PGE_SDLMixerX INTERFACE mingw32 "${SDL2_main_A_Lib}" "${SDL2_SO_Lib}" )
elseif(WIN32 AND MSVC)
    target_link_libraries(PGE_SDLMixerX INTERFACE "${SDL2_main_A_Lib}" "${SDL2_SO_Lib}")
else()
    target_link_libraries(PGE_SDLMixerX INTERFACE "${SDL2_SO_Lib}")
endif()

target_link_libraries(PGE_SDLMixerX_static INTERFACE
    "${SDL_MixerX_A_Lib}"
    "${SDL2_A_Lib}"
)

if(PGE_SHARED_SDLMIXER AND NOT WIN32)
    install(FILES ${SDL_MixerX_SO_Lib} DESTINATION "${PGE_INSTALL_DIRECTORY}")
endif()
