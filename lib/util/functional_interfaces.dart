/// Here goes a list of commonly used functional interfaces.

/// Simple runnable doing things without return value nor arguments.
typedef void Runnable();

/// A supplier provides a value when calling.
typedef T Supplier<T>();

/// Simple function provides a value for an argument.
typedef R Func<R, T>(T argument);

/// Function with two arguments.
typedef R BiFunc<R, T, U>(T argument1, U argument2);

/// Consumer consume things (Do stuff with it).
/// Simple callbacks are an excellent example.
typedef void Consumer<T>(T consume);

/// BiConsumer is like Consumer but consumes two instead of one value.
typedef void BiConsumer<T, U>(T consume1, U consume2);
