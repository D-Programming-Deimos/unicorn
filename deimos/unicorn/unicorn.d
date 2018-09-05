/* Unicorn Emulator Engine */
/* By Nguyen Anh Quynh <aquynh@gmail.com>, 2015 */

module unicorn.unicorn;
extern(C):

struct uc_engine;

struct uc_hook { private size_t typedef; }

enum UC_API_MAJOR = 1;
enum UC_API_MINOR = 0;

/// Unicorn package version
enum UC_VERSION_MAJOR = UC_API_MAJOR;
enum UC_VERSION_MINOR = UC_API_MINOR;
enum UC_VERSION_EXTRA = 1;


/*
  Macro to create combined version which can be compared to
  result of uc_version() API.
*/
int UC_MAKE_VERSION(int major, int minor) { return (major << 8) + minor; }

/// Scales to calculate timeout on microsecond unit
/// 1 second = 1000,000 microseconds
enum UC_SECOND_SCALE = 1000000;
/// 1 milisecond = 1000 nanoseconds
enum UC_MILISECOND_SCALE = 1000;

/// Architecture type
enum uc_arch {
    ARM = 1,    /// ARM architecture (including Thumb, Thumb-2)
    ARM64,      /// ARM-64, also called AArch64
    MIPS,       /// Mips architecture
    X86,        /// X86 architecture (including x86 & x86-64)
    PPC,        /// PowerPC architecture (currently unsupported)
    SPARC,      /// Sparc architecture
    M68K,       /// M68K architecture
    MAX,
}

/// Mode type
enum uc_mode {
    LITTLE_ENDIAN = 0,    /// little-endian mode (default mode)
    BIG_ENDIAN = 1 << 30, /// big-endian mode
    /// arm / arm64
    ARM = 0,              /// ARM mode
    THUMB = 1 << 4,       /// THUMB mode (including Thumb-2)
    MCLASS = 1 << 5,      /// ARM's Cortex-M series (currently unsupported)
    V8 = 1 << 6,          /// ARMv8 A32 encodings for ARM (currently unsupported)
    /// mips
    MICRO = 1 << 4,       /// MicroMips mode (currently unsupported)
    MIPS3 = 1 << 5,       /// Mips III ISA (currently unsupported)
    MIPS32R6 = 1 << 6,    /// Mips32r6 ISA (currently unsupported)
    MIPS32 = 1 << 2,      /// Mips32 ISA
    MIPS64 = 1 << 3,      /// Mips64 ISA
    /// x86 / x64
    X86_16 = 1 << 1,      /// 16-bit mode
    X86_32 = 1 << 2,      /// 32-bit mode
    X86_64 = 1 << 3,      /// 64-bit mode
    /// ppc 
    PPC32 = 1 << 2,       /// 32-bit mode (currently unsupported)
    PPC64 = 1 << 3,       /// 64-bit mode (currently unsupported)
    QPX = 1 << 4,         /// Quad Processing eXtensions mode (currently unsupported)
    /// sparc
    SPARC32 = 1 << 2,     /// 32-bit mode
    SPARC64 = 1 << 3,     /// 64-bit mode
    V9 = 1 << 4,          /// SparcV9 mode (currently unsupported)
    /// m68k
}

/// All type of errors encountered by Unicorn API.
/// These are values returned by uc_errno()
enum uc_err {
    OK = 0,   /// No error: everything was fine
    NOMEM,      /// Out-Of-Memory error: uc_open(), uc_emulate()
    ARCH,     /// Unsupported architecture: uc_open()
    HANDLE,   /// Invalid handle
    MODE,     /// Invalid/unsupported mode: uc_open()
    VERSION,  /// Unsupported version (bindings)
    READ_UNMAPPED, /// Quit emulation due to READ on unmapped memory: uc_emu_start()
    WRITE_UNMAPPED, /// Quit emulation due to WRITE on unmapped memory: uc_emu_start()
    FETCH_UNMAPPED, /// Quit emulation due to FETCH on unmapped memory: uc_emu_start()
    HOOK,    /// Invalid hook type: uc_hook_add()
    INSN_INVALID, /// Quit emulation due to invalid instruction: uc_emu_start()
    MAP, /// Invalid memory mapping: uc_mem_map()
    WRITE_PROT, /// Quit emulation due to UC_MEM_WRITE_PROT violation: uc_emu_start()
    READ_PROT, /// Quit emulation due to UC_MEM_READ_PROT violation: uc_emu_start()
    FETCH_PROT, /// Quit emulation due to UC_MEM_FETCH_PROT violation: uc_emu_start()
    ARG,     /// Inavalid argument provided to uc_xxx function (See specific function API)
    READ_UNALIGNED,  /// Unaligned read
    WRITE_UNALIGNED,  /// Unaligned write
    FETCH_UNALIGNED,  /// Unaligned fetch
    HOOK_EXIST,  /// hook for this event already existed
    RESOURCE,    /// Insufficient resource: uc_emu_start()
    EXCEPTION /// Unhandled CPU exception
}


/*
  Callback function for tracing code (UC_HOOK_CODE & UC_HOOK_BLOCK)

  @address: address where the code is being executed
  @size: size of machine instruction(s) being executed, or 0 when size is unknown
  @user_data: user data passed to tracing APIs.
*/
alias uc_cb_hookcode_t = void function(uc_engine *uc, ulong address, uint size, void *user_data);

/*
  Callback function for tracing interrupts (for uc_hook_intr())

  @intno: interrupt number
  @user_data: user data passed to tracing APIs.
*/
alias uc_cb_hookintr_t = void function(uc_engine *uc, uint intno, void *user_data);

/*
  Callback function for tracing IN instruction of X86

  @port: port number
  @size: data size (1/2/4) to be read from this port
  @user_data: user data passed to tracing APIs.
*/
alias uc_cb_insn_in_t = uint function(uc_engine *uc, uint port, int size, void *user_data);

/*
  Callback function for OUT instruction of X86

  @port: port number
  @size: data size (1/2/4) to be written to this port
  @value: data value to be written to this port
*/
alias uc_cb_insn_out_t = void function(uc_engine *uc, uint port, int size, uint value, void *user_data);

/// All type of memory accesses for UC_HOOK_MEM_*
enum uc_mem_type {
    READ = 16,   /// Memory is read from
    WRITE,       /// Memory is written to
    FETCH,       /// Memory is fetched
    READ_UNMAPPED,    /// Unmapped memory is read from
    WRITE_UNMAPPED,   /// Unmapped memory is written to
    FETCH_UNMAPPED,   /// Unmapped memory is fetched
    WRITE_PROT,  /// Write to write protected, but mapped, memory
    READ_PROT,   /// Read from read protected, but mapped, memory
    FETCH_PROT,  /// Fetch from non-executable, but mapped, memory
    READ_AFTER,   /// Memory is read from (successful access)
}

/// All type of hooks for uc_hook_add() API.
enum uc_hook_type {
    //// Hook all interrupt/syscall events
    INTR = 1 << 0,
    //// Hook a particular instruction - only a very small subset of instructions supported here
    INSN = 1 << 1,
    //// Hook a range of code
    CODE = 1 << 2,
    //// Hook basic blocks
    BLOCK = 1 << 3,
    //// Hook for memory read on unmapped memory
    MEM_READ_UNMAPPED = 1 << 4,
    //// Hook for invalid memory write events
    MEM_WRITE_UNMAPPED = 1 << 5,
    //// Hook for invalid memory fetch for execution events
    MEM_FETCH_UNMAPPED = 1 << 6,
    //// Hook for memory read on read-protected memory
    MEM_READ_PROT = 1 << 7,
    //// Hook for memory write on write-protected memory
    MEM_WRITE_PROT = 1 << 8,
    //// Hook for memory fetch on non-executable memory
    MEM_FETCH_PROT = 1 << 9,
    //// Hook memory read events.
    MEM_READ = 1 << 10,
    //// Hook memory write events.
    MEM_WRITE = 1 << 11,
    //// Hook memory fetch for execution events
    MEM_FETCH = 1 << 12,
    //// Hook memory read events, but only successful access.
    //// The callback will be triggered after successful read.
    MEM_READ_AFTER = 1 << 13,

    //// Hook type for all events of unmapped memory access
    MEM_UNMAPPED = MEM_READ_UNMAPPED + MEM_WRITE_UNMAPPED + MEM_FETCH_UNMAPPED,
    //// Hook type for all events of illegal protected memory access
    MEM_PROT = MEM_READ_PROT + MEM_WRITE_PROT + MEM_FETCH_PROT,
    //// Hook type for all events of illegal read memory access
    MEM_READ_INVALID = MEM_READ_PROT + MEM_READ_UNMAPPED,
    //// Hook type for all events of illegal write memory access
    MEM_WRITE_INVALID = MEM_WRITE_PROT + MEM_WRITE_UNMAPPED,
    //// Hook type for all events of illegal fetch memory access
    MEM_FETCH_INVALID = MEM_FETCH_PROT + MEM_FETCH_UNMAPPED,
    //// Hook type for all events of illegal memory access
    MEM_INVALID = MEM_UNMAPPED + MEM_PROT,
    //// Hook type for all events of valid memory access
    MEM_VALID = MEM_READ + MEM_WRITE + MEM_FETCH,
}

/*
  Callback function for hooking memory (UC_MEM_READ, UC_MEM_WRITE & UC_MEM_FETCH)

  @type: this memory is being READ, or WRITE
  @address: address where the code is being executed
  @size: size of data being read or written
  @value: value of data being written to memory, or irrelevant if type = READ.
  @user_data: user data passed to tracing APIs
*/
alias uc_cb_hookmem_t = void function(uc_engine *uc, uc_mem_type type,
        ulong address, int size, long value, void *user_data);

/*
  Callback function for handling invalid memory access events (UC_MEM_*_UNMAPPED and
    UC_MEM_*PROT events)

  @type: this memory is being READ, or WRITE
  @address: address where the code is being executed
  @size: size of data being read or written
  @value: value of data being written to memory, or irrelevant if type = READ.
  @user_data: user data passed to tracing APIs

  @return: return true to continue, or false to stop program (due to invalid memory).
*/
alias uc_cb_eventmem_t = bool function(uc_engine *uc, uc_mem_type type,
        ulong address, int size, long value, void *user_data);

/*
  Memory region mapped by uc_mem_map() and uc_mem_map_ptr()
  Retrieve the list of memory regions with uc_mem_regions()
*/
struct uc_mem_region {
    ulong begin; /// begin address of the region (inclusive)
    ulong end;   /// end address of the region (inclusive)
    uint perms; /// memory permissions of the region
}

/// All type of queries for uc_query() API.
enum uc_query_type {
    /// Dynamically query current hardware mode.
    MODE = 1,
    PAGE_SIZE,
}

/// Opaque storage for CPU context, used with uc_context_*()
struct uc_context;

/*
 Return combined API version & major and minor version numbers.

 @major: major number of API version
 @minor: minor number of API version

 @return hexical number as (major << 8 | minor), which encodes both
     major & minor versions.
     NOTE: This returned value can be compared with version number made
     with macro UC_MAKE_VERSION

 For example, second API version would return 1 in @major, and 1 in @minor
 The return value would be 0x0101

 NOTE: if you only care about returned value, but not major and minor values,
 set both @major & @minor arguments to NULL.
*/
uint uc_version(uint *major, uint *minor);


/*
 Determine if the given architecture is supported by this library.

 @arch: architecture type (UC_ARCH_*)

 @return True if this library supports the given arch.
*/
bool uc_arch_supported(uc_arch arch);


/*
 Create new instance of unicorn engine.

 @arch: architecture type (UC_ARCH_*)
 @mode: hardware mode. This is combined of UC_MODE_*
 @uc: pointer to uc_engine, which will be updated at return time

 @return UC_ERR_OK on success, or other value on failure (refer to uc_err enum
   for detailed error).
*/
uc_err uc_open(uc_arch arch, uc_mode mode, uc_engine **uc);

/*
 Close UC instance: MUST do to release the handle when it is not used anymore.
 NOTE: this must be called only when there is no longer usage of Unicorn.
 The reason is the this API releases some cached memory, thus access to any
 Unicorn API after uc_close() might crash your application.
 After this, @uc is invalid, and nolonger usable.

 @uc: pointer to a handle returned by uc_open()

 @return UC_ERR_OK on success, or other value on failure (refer to uc_err enum
   for detailed error).
*/
uc_err uc_close(uc_engine *uc);

/*
 Query internal status of engine.

 @uc: handle returned by uc_open()
 @type: query type. See uc_query_type

 @result: save the internal status queried

 @return: error code of uc_err enum type (UC_ERR_*, see above)
*/
uc_err uc_query(uc_engine *uc, uc_query_type type, size_t *result);

/*
 Report the last error number when some API function fail.
 Like glibc's errno, uc_errno might not retain its old value once accessed.

 @uc: handle returned by uc_open()

 @return: error code of uc_err enum type (UC_ERR_*, see above)
*/
uc_err uc_errno(uc_engine *uc);

/*
 Return a string describing given error code.

 @code: error code (see UC_ERR_* above)

 @return: returns a pointer to a string that describes the error code
   passed in the argument @code
 */
const(char)* uc_strerror(uc_err code);

/*
 Write to register.

 @uc: handle returned by uc_open()
 @regid:  register ID that is to be modified.
 @value:  pointer to the value that will set to register @regid

 @return UC_ERR_OK on success, or other value on failure (refer to uc_err enum
   for detailed error).
*/
uc_err uc_reg_write(uc_engine *uc, int regid, const void *value);

/*
 Read register value.

 @uc: handle returned by uc_open()
 @regid:  register ID that is to be retrieved.
 @value:  pointer to a variable storing the register value.

 @return UC_ERR_OK on success, or other value on failure (refer to uc_err enum
   for detailed error).
*/
uc_err uc_reg_read(uc_engine *uc, int regid, void *value);

/*
 Write multiple register values.

 @uc: handle returned by uc_open()
 @rges:  array of register IDs to store
 @value: pointer to array of register values
 @count: length of both *regs and *vals

 @return UC_ERR_OK on success, or other value on failure (refer to uc_err enum
   for detailed error).
*/
uc_err uc_reg_write_batch(uc_engine *uc, int *regs, const void **vals, int count);

/*
 Read multiple register values.

 @uc: handle returned by uc_open()
 @rges:  array of register IDs to retrieve
 @value: pointer to array of values to hold registers
 @count: length of both *regs and *vals

 @return UC_ERR_OK on success, or other value on failure (refer to uc_err enum
   for detailed error).
*/
uc_err uc_reg_read_batch(uc_engine *uc, int *regs, void **vals, int count);

/*
 Write to a range of bytes in memory.

 @uc: handle returned by uc_open()
 @address: starting memory address of bytes to set.
 @bytes:   pointer to a variable containing data to be written to memory.
 @size:   size of memory to write to.

 NOTE: @bytes must be big enough to contain @size bytes.

 @return UC_ERR_OK on success, or other value on failure (refer to uc_err enum
   for detailed error).
*/
uc_err uc_mem_write(uc_engine *uc, ulong address, const void *bytes, size_t size);

/*
 Read a range of bytes in memory.

 @uc: handle returned by uc_open()
 @address: starting memory address of bytes to get.
 @bytes:   pointer to a variable containing data copied from memory.
 @size:   size of memory to read.

 NOTE: @bytes must be big enough to contain @size bytes.

 @return UC_ERR_OK on success, or other value on failure (refer to uc_err enum
   for detailed error).
*/
uc_err uc_mem_read(uc_engine *uc, ulong address, void *bytes, size_t size);

/*
 Emulate machine code in a specific duration of time.

 @uc: handle returned by uc_open()
 @begin: address where emulation starts
 @until: address where emulation stops (i.e when this address is hit)
 @timeout: duration to emulate the code (in microseconds). When this value is 0,
        we will emulate the code in infinite time, until the code is finished.
 @count: the number of instructions to be emulated. When this value is 0,
        we will emulate all the code available, until the code is finished.

 @return UC_ERR_OK on success, or other value on failure (refer to uc_err enum
   for detailed error).
*/
uc_err uc_emu_start(uc_engine *uc, ulong begin, ulong until, ulong timeout, size_t count);

/*
 Stop emulation (which was started by uc_emu_start() API.
 This is typically called from callback functions registered via tracing APIs.

 @uc: handle returned by uc_open()

 @return UC_ERR_OK on success, or other value on failure (refer to uc_err enum
   for detailed error).
*/
uc_err uc_emu_stop(uc_engine *uc);

/*
 Register callback for a hook event.
 The callback will be run when the hook event is hit.

 @uc: handle returned by uc_open()
 @hh: hook handle returned from this registration. To be used in uc_hook_del() API
 @type: hook type
 @callback: callback to be run when instruction is hit
 @user_data: user-defined data. This will be passed to callback function in its
      last argument @user_data
 @begin: start address of the area where the callback is effect (inclusive)
 @end: end address of the area where the callback is effect (inclusive)
   NOTE 1: the callback is called only if related address is in range [@begin, @end]
   NOTE 2: if @begin > @end, callback is called whenever this hook type is triggered
 @...: variable arguments (depending on @type)
   NOTE: if @type = UC_HOOK_INSN, this is the instruction ID (ex: UC_X86_INS_OUT)

 @return UC_ERR_OK on success, or other value on failure (refer to uc_err enum
   for detailed error).
*/
uc_err uc_hook_add(uc_engine *uc, uc_hook *hh, int type, void *callback,
        void *user_data, ulong begin, ulong end, ...);

/*
 Unregister (remove) a hook callback.
 This API removes the hook callback registered by uc_hook_add().
 NOTE: this should be called only when you no longer want to trace.
 After this, @hh is invalid, and nolonger usable.

 @uc: handle returned by uc_open()
 @hh: handle returned by uc_hook_add()

 @return UC_ERR_OK on success, or other value on failure (refer to uc_err enum
   for detailed error).
*/
uc_err uc_hook_del(uc_engine *uc, uc_hook hh);

enum uc_prot {
   NONE = 0,
   READ = 1,
   WRITE = 2,
   EXEC = 4,
   ALL = 7,
}

/*
 Map memory in for emulation.
 This API adds a memory region that can be used by emulation.

 @uc: handle returned by uc_open()
 @address: starting address of the new memory region to be mapped in.
    This address must be aligned to 4KB, or this will return with UC_ERR_ARG error.
 @size: size of the new memory region to be mapped in.
    This size must be multiple of 4KB, or this will return with UC_ERR_ARG error.
 @perms: Permissions for the newly mapped region.
    This must be some combination of UC_PROT_READ | UC_PROT_WRITE | UC_PROT_EXEC,
    or this will return with UC_ERR_ARG error.

 @return UC_ERR_OK on success, or other value on failure (refer to uc_err enum
   for detailed error).
*/
uc_err uc_mem_map(uc_engine *uc, ulong address, size_t size, uint perms);

/*
 Map existing host memory in for emulation.
 This API adds a memory region that can be used by emulation.

 @uc: handle returned by uc_open()
 @address: starting address of the new memory region to be mapped in.
    This address must be aligned to 4KB, or this will return with UC_ERR_ARG error.
 @size: size of the new memory region to be mapped in.
    This size must be multiple of 4KB, or this will return with UC_ERR_ARG error.
 @perms: Permissions for the newly mapped region.
    This must be some combination of UC_PROT_READ | UC_PROT_WRITE | UC_PROT_EXEC,
    or this will return with UC_ERR_ARG error.
 @ptr: pointer to host memory backing the newly mapped memory. This host memory is
    expected to be an equal or larger size than provided, and be mapped with at
    least PROT_READ | PROT_WRITE. If it is not, the resulting behavior is undefined.

 @return UC_ERR_OK on success, or other value on failure (refer to uc_err enum
   for detailed error).
*/
uc_err uc_mem_map_ptr(uc_engine *uc, ulong address, size_t size, uint perms, void *ptr);

/*
 Unmap a region of emulation memory.
 This API deletes a memory mapping from the emulation memory space.

 @uc: handle returned by uc_open()
 @address: starting address of the memory region to be unmapped.
    This address must be aligned to 4KB, or this will return with UC_ERR_ARG error.
 @size: size of the memory region to be modified.
    This size must be multiple of 4KB, or this will return with UC_ERR_ARG error.

 @return UC_ERR_OK on success, or other value on failure (refer to uc_err enum
   for detailed error).
*/
uc_err uc_mem_unmap(uc_engine *uc, ulong address, size_t size);

/*
 Set memory permissions for emulation memory.
 This API changes permissions on an existing memory region.

 @uc: handle returned by uc_open()
 @address: starting address of the memory region to be modified.
    This address must be aligned to 4KB, or this will return with UC_ERR_ARG error.
 @size: size of the memory region to be modified.
    This size must be multiple of 4KB, or this will return with UC_ERR_ARG error.
 @perms: New permissions for the mapped region.
    This must be some combination of UC_PROT_READ | UC_PROT_WRITE | UC_PROT_EXEC,
    or this will return with UC_ERR_ARG error.

 @return UC_ERR_OK on success, or other value on failure (refer to uc_err enum
   for detailed error).
*/
uc_err uc_mem_protect(uc_engine *uc, ulong address, size_t size, uint perms);

/*
 Retrieve all memory regions mapped by uc_mem_map() and uc_mem_map_ptr()
 This API allocates memory for @regions, and user must free this memory later
 by free() to avoid leaking memory.
 NOTE: memory regions may be splitted by uc_mem_unmap()

 @uc: handle returned by uc_open()
 @regions: pointer to an array of uc_mem_region struct. This is allocated by
   Unicorn, and must be freed by user later with uc_free()
 @count: pointer to number of struct uc_mem_region contained in @regions

 @return UC_ERR_OK on success, or other value on failure (refer to uc_err enum
   for detailed error).
*/
uc_err uc_mem_regions(uc_engine *uc, uc_mem_region **regions, uint *count);

/*
 Allocate a region that can be used with uc_context_{save,restore} to perform
 quick save/rollback of the CPU context, which includes registers and some
 internal metadata. Contexts may not be shared across engine instances with
 differing arches or modes.

 @uc: handle returned by uc_open()
 @context: pointer to a uc_engine*. This will be updated with the pointer to
   the new context on successful return of this function.
   Later, this allocated memory must be freed with uc_free().

 @return UC_ERR_OK on success, or other value on failure (refer to uc_err enum
   for detailed error).
*/
uc_err uc_context_alloc(uc_engine *uc, uc_context **context);

/*
 Free the memory allocated by uc_context_alloc & uc_mem_regions.

 @mem: memory allocated by uc_context_alloc (returned in *context), or
       by uc_mem_regions (returned in *regions)

 @return UC_ERR_OK on success, or other value on failure (refer to uc_err enum
   for detailed error).
*/
uc_err uc_free(void *mem);

/*
 Save a copy of the internal CPU context.
 This API should be used to efficiently make or update a saved copy of the
 internal CPU state.

 @uc: handle returned by uc_open()
 @context: handle returned by uc_context_alloc()

 @return UC_ERR_OK on success, or other value on failure (refer to uc_err enum
   for detailed error).
*/
uc_err uc_context_save(uc_engine *uc, uc_context *context);

/*
 Restore the current CPU context from a saved copy.
 This API should be used to roll the CPU context back to a previous
 state saved by uc_context_save().

 @uc: handle returned by uc_open()
 @buffer: handle returned by uc_context_alloc that has been used with uc_context_save

 @return UC_ERR_OK on success, or other value on failure (refer to uc_err enum
   for detailed error).
*/
uc_err uc_context_restore(uc_engine *uc, uc_context *context);
