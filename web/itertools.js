// idk if this should be in the main file or not
export function* chain(...iterables) {
    for (const iterable of iterables) {
        yield* iterable
    }
}

export  function* izip(...iterables) {
    let iterators = iterables.map(iter=>iter[Symbol.iterator]())
    while (iterators) {
        let results = iterators.map(iter=>iter.next())
        if (results.some(({done}) => done)) break
        yield results.map(res=>res.value)
    }
}
