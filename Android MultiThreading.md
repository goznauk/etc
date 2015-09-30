Contents

1. Android Threads
    1.1. UI, Binder, Background Thread
    1.2. Blocking UI Thread and ANR

2. MultiThreading
    2.1. Basic Usage
    2.2. Multithreading Considerations
    2.3. Thread Safety
    2.4. Task Execution Strategies
    2.5. MultiThreading on Android : UI Thread Only

3. Thread Communication in Java
    3.1. Pipes
    3.2. Shared Memory
    3.3. Blocking Queue

4. Thread Communication in Android
    4.1. Android Message handling Mechansim
    4.2. Message
    4.3. Looper
    4.4. Handler
    4.5. HandlerThread

5. Asynctask
    5.1. Overall
    5.2. Usage
    5.3. Pitfalls

6. Executor
    later...

7. IntentService
    later..

8. Loader
    later

9. Select MultiThreading Method
    Matrix?


---



안드로이드 애플리케이션을 개발하다 보면 비동기 작업이나 UI 반응을 위해 스레드를 사용할 일이 많이 생긴다. 안드로이드에서는 멀티스레딩을 위해 몇 가지 방법을 제공하고 있으며, API 문서만 읽고도 손쉽게 적용할 수 있게 되어 있으나 자세하게 정리하고자 이 글을 작성하였다.

###1. Android Threads

안드로이드 애플리케이션이 시작되는 과정을 살펴보면, Linux Process를 만들고, 그 위에 Dalvik VM runtime을 띄워 Application Class의 Instance를 생성, Instance가 가지고 있는 Entry Point Component를 실행한다. 이 과정에서 Linux Process와 Dalvik VM을 관리하는 많은 스레드들이 생성되는데, 이 중 UI thread와 Binder thread는 Application에서 사용되며, Application이 자체적으로 Background thread를 만들어 사용할 수도 있다.

####1.1. UI, Binder, Background Thread

안드로이드 애플리케이션에서 사용하는 모든 스레드는 Linux native pthread(POSIX Thread)의 자바 구현체이다. 하지만 Android Platform은 역할에 따라 UI, Binder, Background thread로 나누어 각각에 특별한 속성들을 부여했다.

UI Thread는 간단히 말하면 Main thread이다. 애플리케이션이 시작되어 프로세스가 종료될 때까지 유지되며, UI elements에 접근할 수 있는 유일한 스레드이다. (모든 Thread는 Linux native thread로 Linux에서는 동등하게 취급되기 때문에 Application Framework Layer의 WindowManager에서 UI thread 이외의 접근을 제한한다) Activity에서 실행하는 코드들은 별다른 스레딩을 하지 않았다면 UI thread에서 실행된다. UI elements들의 이벤트들을 순차적으로 처리하기 때문에 시간이 오래 걸리는 이벤트를 실행하면 UI 전체가 멈추게 된다.

Binder Thread는 IPC(InterProcess Communication)를 위한 스레드로, 모든 프로세스는 Binder thread를 위한 thread pool을 가진다. 이 스레드풀은 임의로 제거되거나 생성할 수 없으며, Intent, Content Provider, Service 등 다른 프로세스의 요청을 핸들링하게 된다. Binder를 사용할 경우를 제외하고는 생각하지 않아도 되는 thread로, Binder란 Linux IPC를 대체한 안드로이드 커널만의 프레임워크로, 프로세스 간의 RPC(Remote Procedure Calls)를 제공하는 것인데, 추후에 다른 글에서 다루기로 한다.

Background Thread는 애플리케이션이 필요할 때 생성하는 thread로 UI thread의 속성들을 상속받는다. 자유롭게 생성하고 실행이 가능하며, 일반적인 애플리케이션을 개발할 때 가장 신경써야 할 thread이다. 앞으로 다룰 Threading에 관한 내용은 거의 Background Thread에 대한 내용이라고 볼 수 있다.

####1.2. Blocking UI Thread and ANR

사용자와 인터렉션하는 GUI 애플리케이션들의 경우, 사용자경험 측면에서 즉각적인 응답을 주는 것이 매우 중요하다. 사용자는 화면이 멈추고 아무런 입력도 할 수 없는 상태가 자주 일어나는 애플리케이션에 결코 좋은 평가를 하지 않을 것이다. 이런 이유로 윈도우의 ‘응답 없음’과 같이, 어떤 이벤트가 발생한 후 일정 시간동안 응답이 없는 경우 OS단에서 앱을 중지할 것인지 물어보는 (과격한) 정책들이 사용되고 있다.

Android에서는 UI Thread가 UI elements들의 이벤트들을 순차적으로 실행하는 까닭에 어떤 element의 이벤트가 오랜 시간 실행된다면 전체 UI가 다른 이벤트를 받지 못하고 멈추게 된다. 이 상태로 약 5초가 지나면 Android OS는 ANR(Application Not Responding) 메시지를 띄우며 사용자가 앱을 종료할 것인지 묻게 된다. 이 때 사용자가 당신의 애플리케이션이 완벽하다는 믿음을 가지고 종료하지 않고 기다려 주는 경우는 사용자가 당신 혹은 당신의 동료일 경우 뿐이다. 대부분의 사용자는 망설이지 않고 종료 버튼을 누를 것이며, 다시는 당신의 애플리케이션을 이용하지 않을 확률이 높다.

이 경우 사용자에게 비현실적인 것을 기대하기보다는 Background Thread를 사용해 비동기적으로 처리해 주고, 기다리는 동안은 처리되고 있다는 알림을 - 필수는 아니지만 - 띄우는 편이 사용자에게 더 큰 만족감을 줄 것이다. 더 나아가 안드로이드는 시간이 많이 걸리는 작업들 - 네트워크 등(더 찾아보기) - 을 Background Thread에서 처리하도록 (찾아봐야댐)버전 몇부터는 정책적으로 강제하였다. 다시 말해 Background Thread을 사용해야 하는 부분은 안드로이드 개발에 있어 빼놓을 수 없는 부분이며, Android MultiThreading에 대한 깊은 이해가 필요하다고 볼 수 있다.

###2. MultiThreading

안드로이드의 스레드에 대해 더 살펴보기 전에, 기본적인 스레드에 대해 더 알아보자. 스레드란 프로세스 내에서 실행되는 흐름의 단위를 뜻하는 말로, 코드의 실행 흐름을 새로 만들 때 사용된다. 일반적으로 한 프로세스는 하나 이상의 스레드를 가지는데, 한 스레드 안에서 코드는 항상 순차적으로 실행된다.

(예시 수정할 것)
이해를 돕기 위해 라면을 끓이는 상황을 생각해 보자. 

> 불을 켜고(Task A) 1초에 한 번씩 물이 끓는 지 보다 물이 끓으면(wait) 라면을 넣는다(Task B)는 코드를 한 스레드 안에서 실행하면 불을 켜고(Task A 실행) 가만히 서서 냄비를 바라보다(wait) 라면을 넣을 것이다(Task B 실행).

위의 예시에서 당신은 물이 끓을 때까지 1초에 한번씩 냄비를 확인하며 가만히 서있어야 할 것이다. 다행스럽게도, 당신에게는 Thread라는 로봇이 있다. 불을 켜고(Task A) Thread를 불러(thread 생성) 물이 끓는 것을 확인한 후(wait) 면을 넣으라(Task B)는 이야기를 해 놓고 쇼파에 누워 페이스북(Task C)을 할 수 있을 것이다.

####2.1. Basic Usage

Java의 Thread는 `java.lang.Thread`에 구현되어 있다. Thread는 어떤 task를 실행하면서 시작되고, task의 실행이 끝나 더 이상 실행할 task가 없는 경우 제거된다. task의 구현은 `java.lang.Runnable` interface를 통해 구현할 수 있다. 기본적인 thread의 사용법은 다음과 같다.

```java
class CountTask implements Runnable {
    public void run() {
        count = 0;
        while(count<5) {
            System.out.println(“Count: “ + count);
            count++;
        }
    }
}

Thread otherThread = new Thread(new CountTask());
otherThread.start();
```

위 코드에서 CountTask의 `run()` 메서드 내부의 변수는 새로 만들어진 otherThread의 local memory stack에 저장된다. 각각의 thread는 각각의 instruction pointer와 stack pointer를 가지며, 이 stack pointer는 thread-local memory stack의 변수를 가리킨다. thread-local memory stack은 다른 스레드에서 접근할 수 없는 영역이다.

####2.2. Multithreading Considerations

여러 개의 스레드를 사용함으로서 얻는 이점들도 있지만, 그에 대해 지불해야 하는 cost도 적지 않다. 모든 코드가 순차적으로 실행되는 Single-threaded 애플리케이션에 비해 MultiThreaded 애플리케이션의 경우 스레드 수만큼의 실행 흐름에 대해 고려해야 하며, 그에 따라 에러가 발생할 확률이 높아지고 디버깅이 어려워진다. 서로 다른 스레드 - 실행 흐름 - 상에서 돌아가는 코드들의 순서가 nondeterministic하기 때문에 고려해야 할 문제도 많다. 단순하게 코드가 복잡하고 예측하기 어려워지는 것 뿐 아니라 공유된 자원에 접근할 경우 의도대로 코드가 작동하지 않는 문제가 있다.

예를 들어, 두 스레드 A, B가 있다고 하자. 두 스레드 A, B는 모두 공유된 자원 `count`에 접근하는데, A는 `count`를 증가시키고, B는 감소시킨다. Java 코드로 표현하면 다음과 같다.

```java
public class RaceCondition {
    int count;

    public static void main(String[] args) {
        count = 0;
        Thread threadA = new Thread(new Runnable() {
            @Override
            public void run() {
                count++;
                System.out.println(count);
            }
        });

        Thread threadB = new Thread(new Runnable() {
            @Override
            public void run() {
                count--;
                System.out.println(count);
            }
        });

        threadA.start();
        threadB.start();
        System.out.println(count);
    }
}
```

단순하게 생각했을 때, 출력은 1, 0, 0이 되어야 한다. 그러나 위 코드를 실행해 보면, 출력은 항상 - 같은 환경에서 테스트할 경우 확률적으로 한 개의 결과를 더 많이 보여줄 수는 있으나 - 다른 결과를 보여준다. 스레드 A가 B보다 먼저 실행된느 것을 보장할 수 없다는 것이다. 비단 실행 순서의 문제일까? 세 번째 출력은 항상 0일까?

최종적으로 `count`가 가지는 값은 0일 수도 있지만, 1 혹은 -1이 될 수도 있다. `count`가 Race Condition(경쟁 상태)에 있기 때문이다. Race Condition이란 공유 자원에 대해 여러 개의 접근이 동시에 이루어지는 상태를 말한다. 다행스럽게도 스레드 B가 A의 작업이 끝난 후 - `count`가 0에서 1로 바뀐 후 - 혹은 A가 B의 작업이 끝난 후에 실행된다면 `count`는 최종적으로 0이 되겠지만, 만약 A와 B가 동시에 - count가 0일 때 - `count`에 접근해 작업을 실행한다면 최종적으로 `count`는 -1이나 1의 값을 가지게 된다.

####2.3. Thread Safety

멀티스레드 환경에서는 위와 같이 공유된 자원에 여러 스레드에서 접근하는 상황이 자주 발생하게 된다. 여러 스레드에서 하나의 자원을 공유하는 것은 하나의 writer와 여러 개의 reader가 있을 경우 성능적인 측면에서 좋은 선택일 수 있지만, 개발자는 항상 실수를 하기 마련이므로 Thread Safety에 대한 고민이 필요하다. Thread Safety란 어떤 함수나 변수, 혹은 객체가 여러 스레드로부터 동시에 접근이 이루어져도 프로그램의 실행에 문제가 없음을 뜻하는 말이다. 하나의 함수가 한 스레드에서 호출되어 실행될 때, 다른 스레드에서 같은 함수를 호출해 동시에 실행되더라도 각각의 스레드에서 함수가 올바르게 작동해야 한다는 것이다.

그렇다면 어떻게 Thread Safety하도록 만들 수 있을까? 공유된 자원이 없도록 만들면 된다. Thread-local storage를 사용하는 등 Re-Enterancy(재진입성)를 가지는 함수만을 사용하면 된다. Re-Enterancy를 가지는 함수란 언제나 다시 실행해도 같은 결과를 가지는 것으로, 간단히 이야기하면 호출 시 제공한 파라미터만으로 동작하는 전역 변수와 무관하게 돌아가는 함수를 말한다. 그러나 공유된 자원을 꼭 사용해야 하는 경우도 있다. 이러한 경우 세마포어 등의 락으로 상호 배제를 만들거나, atomically 하게 실행하도록 - 한 번에 하나의 스레드에서만 실행하도록 - 만들면 된다. 이렇게 atomically하게 실행되는 코드 영역을 critical section(임계영역)이라고 한다.

Java에서는 `synchronized` 키워드나 `java.util.concurrent.locks.ReentrantLock` 패키지를 사용하여 atomic execution을 구현할 수 있다. 두 가지 방법 모두 critical section이 atomical하게 실행되도록 다른 모든 thread를 block하는 방식으로 동작한다.

`synchronized` 키워드는 세 가지 방법으로 사용될 수 있는데, 각각에 대한 예시 코드를 보자.

- 해당 함수가 실행되고 있는 동안 동기화를 보장
```java
public synchronized void someMethod() {
    // Do something...
}
```

- 해당 블록 내에서 동기화를 보장
```java
public void someMethod() {
    // Do Something...
    synchronized(this) {
        // Do something...
    }
    // Do Something...
}
```

- 해당 블록 내에서 해당 변수에 대해 동기화를 보장
```java
public void someMethod(int sth) {
    // Do something...
    synchronized(sth) {
        // Do something...
    }
    // Do something...
}
```

`ReentrantLock`의 경우 `synchronized` 키워드에 비해 더 많은 기능을 제공한다. `ReentrantLock`은 Lock 인터페이스의 구현체로서, 타임아웃애 있는 Lock, Polling Lock 등을 지원한다. Lock 인터페이스와 간단한 사용법을 소개하고 넘어가도록 한다.

- Lock Interface
```java
public interface Lock {
    void lock();
    void lockInterruptibly() throws InterruptedException();
    boolean tryLock();
    boolean tryLock( long timeout, TimeUnit unit() throws InterruptedException();
    void unlock();
    Condition newCondition();
}
```

- Example
```java
Lock mLock = new ReentrantLock();
mLock.lock();
try {
    // Do something...
} finally {
    mLock.unlock();
}
```

ReentrantLock 참고 : http://ismydream.tistory.com/51

####2.4. Task Execution Strategies

여러 개의 스레드를 사용할 경우 스레드를 적재적소에 사용하는 것이 매우 중요한데, 하나의 스레드에서 모든 일을 처리하는 경우 프로그램은 unresponsive하게 될 것이고, task 하나당 하나의 스레드를 사용하는 경우 context switching, thread communication 등의 overhead가 성능을 떨어뜨릴 것이다. 그렇다면 어떻게 task execution을 수행할 것인가? Sequential execution과 Concurrent execution에 대해 살펴보자.

Sequential execution은 task들이 순차적으로 실행되는 것을 말한다. 이 경우 하나의 스레드에서 실행하는 것이 효율적이며, 당연하게도 Thread Safe하다. 하지만 throughput이 낮고, 중간에 오래 걸리는 task가 있다면 그 후의 모든 task들이 delay되거나 실행되지 않을 수 있다.

Concurrent execution의 경우 task들이 parallel하게 실행되기 때문에 CPU를 효율적으로 사용할 수 있으나, Thread Safety를 보장할 수 없으므로 synchronization이 필요하다. Concurrent execution을 구현할 경우 많은 방법이 있으나 thread를 재사용하거나 너무 과도하게 사용하지 않도록 해야 한다.

효율적인 프로그램을 만드려면 실행하려는 task들에 따라 sequential execution과 concurrent execution을 적절히 사용해야 한다.

####2.5. MultiThreading on Android : UI Thread Only

다시 안드로이드로 돌아와 안드로이드의 UI Thread를 살펴보자. 앞서 UI Element에 대한 접근은 Application Framework Layer에서 WindowManager를 통해 제한한다고 이야기했다. 왜 이런 제한을 걸었을까? UI Element를 조작하는 과정을 생각해보자. UI Element들은 단순히 Activity - 혹은 View - 의 인스턴스 필드라고 생각하기 쉬우나, (조사 필요) 실제로는 조금 더 복잡하다. 그러나 UI Element 들에 접근할 때 synchronization에 신경써야 하지는 않는다. Android Runtime이 UI elements들에 대해 single-threaded로 작동하도록 강제함으로서 concurrency problems에 대해 자유로워질 수 있는 것이다.

###3. Thread Communication in Java

지금까지 안드로이드에서 멀티스레딩이 필요한 이유와 방법에 대해 살펴보았다. 안드로이드만의 스레드 통신 방법인 Handler/Looper에 대해 이야기하기 전에 Java의 Thread 통신 방법들을 먼저 알아보자.

####3.1. Pipes

[그림]

`java.io` 패키지의 Pipe는 단방향 데이터 채널을 위해 사용되는 것으로, POSIX의 pipe operator와 비슷한 기능을 하지만, 프로세스 간의 통신을 하는 POSIX pipe와는 달리 VM 위의 스레드 사이에서 output redirecting을 한다. Pipe에 데이터를 쓰는 스레드를 Producer 스레드라 하고, Pipe에서 데이터를 읽는 스레드를 Consumer 스레드라고 한다. Pipe는 circular buffer로서, producer와 consumer thread만 접근 가능한 - 둘 사이에 공유된 - 자원이다. 앞서 Thread Safety 부분에서 언급한 것처럼 한 개의 스레드만 데이터를 조작하고, 나머지 하나의 스레드는 읽기만 하므로 Pipe를 사용하는 것은 Thread Safe한 방법이다.

Pipe는 여러 개의 task를 decouple하기 위한 용도로 많이 쓰이며, 두 개의 long-running task가 있을 경우 한 개의 task가 끝난 후 다음 task가 새로운 스레드에서 실행될 수 있게 해 준다. Pipe는 `PipedInputStream`, `PipedOuputStream`을 통해 binary나 character data를 전달할 수 있게 해 주는데, connection이 형성될 때부터 닫힐 때까지 작동한다. 이 과정을 크게 세 가지로 나누면 setup, data transfer, disconnection으로, 간단한 예시를 보자.

- Set up
```java
PipedInputStream pipedInputStream = new PipedInputStream();
PipedOutputStream pipedOutputStream = new PipedOutputStream();
pipedInputStream.connect(pipedInputStream);
```

- Data transfer
```java
Thread inputThread = new Thread(new Runnable() {
    @Override
    public void run() {
        try {
            String string = "Hello Pipe!";
            pipedOutputStream.write(string.getBytes());
        } catch(IOException e) {
            e.printStackTrace();
        }
    }
});

Thread outputThread = new Thread(new Runnable() {
    @Override
    public void run() {
        try {
            int data = pipedInputStream.read();
            for(; data != -1; data = pipedInputStream.read()) {
                System.out.print((char)data);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
});

inputThread.start();
outputThread.start();
```

위 코드에서 `PipedInputStream.read()`와 `PipedOutputStream.write()`는 blocking call이기 때문에 같은 스레드에서 동시에 read와 write를 하면 deadlock 상태가 되는 것에 주의하라.

- Disconnection
```java
pipedInputStream.close();
pipedOutputStream.close();
```

그렇다면 Android에서 이를 적용시키려면 어떻게 해야 할까? 간단한 예시로 액티비티를 실행하는 동안 어떤 이벤트가 발생하면 worker thread에서 처리하는 상황을 생각해 보자. `onCreate()`시에 위의 `PipedInputStream`과 `PipedOutputStream`을 생성 후 연결시켜 주고, worker thread에서 무한 루프를 돌며 `PipedInputStream`에 data가 있는지 계속 확인하도록 만든다. 이벤트 발생 시에 main thread에서 `PipedOutputStream`에 `write()`를 하도록 하면 Pipe가 비어 있지 않으므로 worker thread에서 data를 받아 처리하게 된다. 이 때 `onDestroy()`에서 stream들을 `close()`하고 worker thread를 `inturrupt()`해야 메모리 낭비가 생기지 않는다. 또한 pipe가 가득 차면 UI thread를 blocking 하게 되므로 buffer size를 충분하게 설정해야 한다.

(sample code 추가할 것)


####3.2. Shared Memory

[그림]

스레드의 특징 중 하나는 한 프로세스 내의 모든 스레드는 각각의 stack 영역을 제외하고는 다른 모든 부분 - Code, Data, Heap 영역을 공유한다는 것이다. 이 Heap 영역을 이용하여 스레드간의 통신을 할 수 있다. Java에서 모든 객체는 Heap 영역에 저장되며, 이 객체들의 reference들은 각각 thread의 stack에 저장된다. 따라서 이 reference만 thread간에 전달해 주면 전달받은 thread는 전달받은 reference가 가리키는 객체에 접근할 수 있게 된다.

만일 두 스레드가 순서대로 실행되야 하며, 두 스레드 간에 Shared Memory를 사용해 통신한다면 어떻게 해야 할까? 앞서 Pipe의 예시처럼 어떤 state를 polling하여 구현할 수 있다. Shared Memory에 state를 나타내는 변수를 만들고, 무한 루프를 돌며 state 변수가 변하는 것을 체크하는 것이다. 이 방법도 물론 잘 동작하지만, 이러한 busy waiting은 성능 저하를 초래한다. Java의 built-in signaling mechanism을 이용하면 더 효율적으로 작동하게 할 수 있는데, `java.lang.Object`에 정의되어 있는 `wait()`, `notify()`, `notifyAll()` 세 개의 메서드를 사용하는 것이다. 간단하게 예시 코드를 통해 사용법을 소개하고 넘어가겠다. 더 자세한 설명은 [이 포스트](http://tutorials.jenkov.com/java-concurrency/thread-signaling.html)를 참고하라.


```java
public class WaitNotify {
    Object lock = new Object();
    boolean wasSignalled = false;

    public void doWait() {
        synchronized(lock) {
            while (!wasSignalled) {
                lock.wait();
            }
        }
        wasSignalled = false;
    }

    public void doNotify() {
        synchronized(lock) {
            wasSignalled = true;
            lock.notify();
        }
    }
    
    public static void main(String[] args) {
        Thread threadA = new Thread(new Runnable() {
            @Override
            public void run() {
                System.out.println("threadA: run() called");
                for(int i = 0; i < 5; i++) {
                    System.out.println("threadA: 0." + i + "s");
                    sleep(100);
                }
                doNotify();
            }
        });

        Thread threadB = new Thread(new Runnable() {
            @Override
            public void run() {
                System.out.println("threadB: run() called");
                doWait();
                System.out.println("threadB: start working");
            }
        });

        threadA.start();
        threadB.start();
    }
}
```

`doNotify()` 함수가 실행되기 전까지는 `wasSignalled`의 값이 `false`이므로 `doWait()`함수에서 `lock.wait()`을 실행하게 된다. `lock` Object에 대해 synchronized 된 블럭 안에 있는 코드는 `lock`객체에 대한 Lock을 획득하기 전까지는 비활성화된다. `threadA`가 시작된지 0.5초가 지나 `doNotify()`가 호출되면 `lock` 객체의 Lock을 반환하고, 그제서야 threadB의 `doWait();`을 벗어나 다음 코드로 넘어가게 된다.

다른 방법으로는 `java.util.concurrent.CountDownLatch`를 사용하는 방법이 있다. `CountDownLatch.await()`, `CountDownLatch.countDown()` 메서드를 사용하는 방법으로, [공식 API 문서](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CountDownLatch.html)에 예제 코드까지 자세하게 나와 있으니 자세한 설명은 생략하도록 하겠다.


####3.3. Blocking Queue

위에서 살펴본 thread signal을 사용하는 방법은 low-level mechansim이기 때문에 use case에 따라 많은 부분을 직접 설정해 사용할 수 있다. 하지만 그만큼 고려해야 할 사항이 많고, 에러를 일으키기 쉽다는 단점이 있기 때문에 Java에서는 단방향 통신에 대해 추상화된 high-level signaling mechansim을 제공한다.

[그림]

`java.util.concurrent.BlockingQueue` 인터페이스들의 구현체로는 여러 가지가 있는데, Array로 구현되어 고정 크기를 가지는 `ArrayBlockingQueue`, Linked List로 구현된 `LinkedBlockingQueue`, Priority를 가지는 `PriorityBlockingQueue`, insert와 remove가 동시에 이루어지는, 크기가 항상 0으로 유지되는 `SynchronousQueue` 등이 있다. [공식 API 문서](http://docs.oracle.com/javase/7/docs/api/java/util/concurrent/BlockingQueue.html)의 예제 코드를 살펴보자.

```java
class Producer implements Runnable {
    private final BlockingQueue queue;
    Producer(BlockingQueue q) { queue = q; }
    public void run() {
        try {
            while (true) { queue.put(produce()); }
        } catch (InterruptedException ex) { ... handle ...}
    }
    Object produce() { ... }
}

class Consumer implements Runnable {
    private final BlockingQueue queue;
    Consumer(BlockingQueue q) { queue = q; }
    public void run() {
        try {
            while (true) { consume(queue.take()); }
        } catch (InterruptedException ex) { ... handle ...}
    }
    void consume(Object x) { ... }
}

class Setup {
    void main() {
        BlockingQueue q = new SomeQueueImplementation();
        Producer p = new Producer(q);
        Consumer c1 = new Consumer(q);
        Consumer c2 = new Consumer(q);
        new Thread(p).start();
        new Thread(c1).start();
        new Thread(c2).start();
    }
}
```

Producer는 `BlockingQueue.put()`을 하고, Consumer는 `BlockingQueue.take()`를 하는 것만으로 Thread Safe한 통신을 구현할 수 있다. 내부적으로 atomical하게 작동하도록 lock을 컨트롤 해 주기 때문이다.


###4. Thread Communication in Android

지금까지 Java의 Thread Communication 방법들에 대해 알아보았다. 앞서 언급한 모든 방법은 Android에서도 같은 방법으로 사용할 수 있으나, 모두 UI 스레드를 block하는 상황 - Queue가 가득 차거나 하는 - 이 발생할 위험이 있다. UI Thread가 block되면 반응성이 저하되고 ANR이 발생 위험이 있으므로, 이 문제를 해결하기 위해서는 nonblocking한 consumer-producer pattern이 필요하다. Android platform에서는 자체적으로 message handling mechanism을 만들어 `android.os` 패키지에서 제공하고 있다.

####4.1. Android Message Handling Mechanism

[그림]






####4.2. Message
####4.3. Looper
####4.4. Handler
####4.5. HandlerThread

http://frontjang.info/443

http://huewu.blog.me/110115454542
http://huewu.blog.me/110116293622

http://blog.nikitaog.me/2014/10/11/android-looper-handler-handlerthread-i/
http://blog.nikitaog.me/2014/10/18/android-looper-handler-handlerthread-ii/
https://corner.squareup.com/2013/10/android-main-thread-1.html
https://corner.squareup.com/2013/12/android-main-thread-2.html
http://codetheory.in/android-handlers-runnables-loopers-messagequeue-handlerthread/



###5. Asynctask

http://suribada.com/wp/?p=13
http://therne.me/?p=76
http://javacan.tistory.com/entry/maintainable-async-processing-code-based-on-AsyncTask
http://blog.danlew.net/2014/06/21/the-hidden-pitfalls-of-asynctask/
http://bon-app-etit.blogspot.kr/2013/04/the-dark-side-of-asynctask.html

####5.1. Overall
####5.2. Usage
####5.3. Pitfalls






###6. Executor
http://blog.bsidesoft.com/?p=311&fb_ref=AL2FB

###7. IntentService
https://realm.io/news/android-threading-background-tasks/

###8. Loader
http://www.vogella.com/tutorials/AndroidBackgroundProcessing/article.html#concurrency_asynchtask_parallel

###9. Select MultiThreading Method
http://www.slideshare.net/andersgoransson/efficient-android-threading