package HelloApp;

/**
* HelloApp/HelloHolder.java .
* Generated by the IDL-to-Java compiler (portable), version "3.2"
* from hello.idl
* 2015년 9월 9일 수요일 오후 2시 33분 36초 KST
*/

public final class HelloHolder implements org.omg.CORBA.portable.Streamable
{
  public HelloApp.Hello value = null;

  public HelloHolder ()
  {
  }

  public HelloHolder (HelloApp.Hello initialValue)
  {
    value = initialValue;
  }

  public void _read (org.omg.CORBA.portable.InputStream i)
  {
    value = HelloApp.HelloHelper.read (i);
  }

  public void _write (org.omg.CORBA.portable.OutputStream o)
  {
    HelloApp.HelloHelper.write (o, value);
  }

  public org.omg.CORBA.TypeCode _type ()
  {
    return HelloApp.HelloHelper.type ();
  }

}