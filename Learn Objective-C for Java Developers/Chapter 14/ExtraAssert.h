/*
 *  ExtraAssert.h
 *
 *  Created by James Bucanek on 12/28/07.
 *  This source code is in the public domain.
 *
 */

// Extra assertion shortcuts
#if !defined(NS_BLOCK_ASSERTIONS)
// These are the master assertion macros, but don't use these directly.
// Use indirectly via DevAssert..., BetaAssert..., or RelAssert..., which can be independently be turned on and off.
#define AssertObjectIsClass(OBJECT,CLASS) \
		do { \
			if (![OBJECT isKindOfClass:[CLASS class]]) { \
				[[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd \
																	object:self \
																	  file:[NSString stringWithUTF8String:__FILE__] \
																lineNumber:__LINE__ \
															   description:@"object isa %@@%p; expected %s",[OBJECT className],OBJECT,#CLASS]; \
			} \
		} while(NO)
#define AssertObjectIsNilOrClass(OBJECT,CLASS) \
		do { \
			if ((OBJECT!=nil) && ![OBJECT isKindOfClass:[CLASS class]]) { \
				[[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd \
																	object:self \
																	  file:[NSString stringWithUTF8String:__FILE__] \
																lineNumber:__LINE__ \
															   description:@"object isa %@@%p; expected %s or nil",[OBJECT className],OBJECT,#CLASS]; \
			} \
		} while(NO)
#define AssertObjectImplements(OBJECT,MESSAGE) \
		do { \
			if (![OBJECT respondsToSelector:@selector(MESSAGE)]) { \
				[[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd \
																	object:self \
																	  file:[NSString stringWithUTF8String:__FILE__] \
																lineNumber:__LINE__ \
															   description:@"object %@@%p does not respond to %s",[OBJECT className],OBJECT,#MESSAGE]; \
			} \
		} while(NO)
#define AssertAbstract()							NSAssert2(false,@"%@ sent abstract message %s",[self className],__func__)
#define AssertNotNil(VALUE)						NSAssert2((VALUE)!=nil,@"%s: %s is nil",__func__,#VALUE)
#define ParameterAssert							NSParameterAssert
#define RethrowAssertion(EXCEPTION) \
        if ([[EXCEPTION name] isEqualToString:NSInternalInconsistencyException]) \
            [EXCEPTION raise]
#endif

// Conditional assertions based on the build type (debug vs. deployment)
// Define IN_DEVELOPMENT in the build settings (or the pre-compiled heade) to enable these assertions
#if IN_DEVELOPMENT
#define DEV_ASSERT_ENABLED 1
#define DevAssert						NSAssert
#define DevAssert1						NSAssert1
#define DevAssert2						NSAssert2
#define DevAssert3						NSAssert3
#define DevAssert4						NSAssert4
#define DevAssert5						NSAssert5
#define DevParameterAssert				ParameterAssert
#define DevAssertObjectIsClass			AssertObjectIsClass
#define DevAssertObjectIsNilOrClass		AssertObjectIsNilOrClass
#define DevAssertObjectImplements		AssertObjectImplements
#define DevAssertAbstract				AssertAbstract
#define DevAssertNotNil					AssertNotNil
#define DevRethrowAssertion				RethrowAssertion
#else
#define DEV_ASSERT_ENABLED 0
#define DevAssert(cond,desc)
#define DevAssert1(cond,desc,arg1)
#define DevAssert2(cond,desc,arg1,arg2)
#define DevAssert3(cond,desc,arg1,arg2,arg3)
#define DevAssert4(cond,desc,arg1,arg2,arg3,arg4)
#define DevAssert5(cond,desc,arg1,arg2,arg3,arg4,arg5)
#define DevParameterAssert(condition)
#define DevAssertObjectIsClass(object,class)
#define DevAssertObjectIsNilOrClass(object,class)
#define DevAssertObjectImplements(object,message)
#define DevAssertAbstract()
#define DevAssertNotNil(value)
#define DevRethrowAssertion(exception)
#endif

// Beta assertions are only enabled for beta releases
// Define VERSION_IS_BETA in the build setting or the precompiled header.
#if VERSION_IS_BETA
#define BETA_ASSERT_ENABLED 1
#define BetaAssert						NSAssert
#define BetaAssert1						NSAssert1
#define BetaAssert2						NSAssert2
#define BetaAssert3						NSAssert3
#define BetaAssert4						NSAssert4
#define BetaAssert5						NSAssert5
#define BetaParameterAssert				ParameterAssert
#define BetaAssertObjectIsClass			AssertObjectIsClass
#define BetaAssertObjectIsNilOrClass	AssertObjectIsNilOrClass
#define BetaAssertObjectImplements		AssertObjectImplements
#define BetaAssertAbstract				AssertAbstract
#define BetaAssertNotNil				AssertNotNil
#define BetaRethrowAssertion			RethrowAssertion
#else
#define BETA_ASSERT_ENABLED 0
#define BetaAssert(cond,desc)
#define BetaAssert1(cond,desc,arg1)
#define BetaAssert2(cond,desc,arg1,arg2)
#define BetaAssert3(cond,desc,arg1,arg2,arg3)
#define BetaAssert4(cond,desc,arg1,arg2,arg3,arg4)
#define BetaAssert5(cond,desc,arg1,arg2,arg3,arg4,arg5)
#define BetaParameterAssert(condition)
#define BetaAssertObjectIsClass(object,class)
#define BetaAssertObjectIsNilOrClass(object,class)
#define BetaAssertObjectImplements(object,message)
#define BetaAssertAbstract()
#define BetaAssertNotNil(value)
#define BetaRethrowAssertion(exception)
#endif

// Release assertions are always enabled (assuming NSAssert is enabled)
#if !defined(NS_BLOCK_ASSERTIONS)
#define RELEASE_ASSERT_ENABLED 1
#define RelAssert						NSAssert
#define RelAssert1						NSAssert1
#define RelAssert2						NSAssert2
#define RelAssert3						NSAssert3
#define RelAssert4						NSAssert4
#define RelAssert5						NSAssert5
#define RelParameterAssert				ParameterAssert
#define RelAssertObjectIsClass			AssertObjectIsClass
#define RelAssertObjectIsNilOrClass		AssertObjectIsNilOrClass
#define RelAssertObjectImplements		AssertObjectImplements
#define RelAssertAbstract				AssertAbstract
#define RelAssertNotNil					AssertNotNil
#define RelRethrowAssertion				RethrowAssertion
#else
#define RELEASE_ASSERT_ENABLED 0
#define RelAssert(cond,desc)
#define RelAssert1(cond,desc,arg1)
#define RelAssert2(cond,desc,arg1,arg2)
#define RelAssert3(cond,desc,arg1,arg2,arg3)
#define RelAssert4(cond,desc,arg1,arg2,arg3,arg4)
#define RelAssert5(cond,desc,arg1,arg2,arg3,arg4,arg5)
#define RelParameterAssert(condition)
#define RelAssertObjectIsClass(object,class)
#define RelAssertObjectIsNilOrClass(object,class)
#define RelAssertObjectImplements(object,message)
#define RelAssertAbstract()
#define RelAssertNotNil(value)
#define RelRethrowAssertion(exception)
#endif
