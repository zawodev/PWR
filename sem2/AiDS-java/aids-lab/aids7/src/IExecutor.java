public interface IExecutor<T, R> {
    void execute (T elem);
    R getResult();
    void reset();
}
