#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>
#include <string.h>

int main() {
    char op[10];
    int num1, num2;

    // keep reading operations until EOF
    while (scanf("%s %d %d", op, &num1, &num2) == 3) {

        char lib_path[20];
        
        // build library name like libadd.so
        snprintf(lib_path, sizeof(lib_path), "./lib%s.so", op);

        // load the shared library
        void *handle = dlopen(lib_path, RTLD_LAZY);
        if (!handle) {
            fprintf(stderr, "Error loading library: %s\n", dlerror());
            continue;
        }

        // clear previous errors
        dlerror();

        // get function from library
        int (*operation)(int, int);
        operation = (int (*)(int, int)) dlsym(handle, op);

        char *error = dlerror();
        if (error != NULL) {
            fprintf(stderr, "Error finding symbol: %s\n", error);
            dlclose(handle);
            continue;
        }

        // run operation and print result
        int result = operation(num1, num2);
        printf("%d\n", result);

        // unload library after use
        dlclose(handle);
    }

    return 0;
}
