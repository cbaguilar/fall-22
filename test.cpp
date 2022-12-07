#include <iostream>
using namespace std;
class Foo {
public:
  Foo(int x) { s_  = x; }
  ~Foo() { s_ -= 1; }
  void print() const { cout << s_ << " "; }
private:
  static int s_;
};

int Foo::s_ = -10;

int main() {
  Foo a(1);
  a.print();
  Foo* p  = new Foo(2);
  a.print();
  p->print();
  Foo c(10);
  delete p;
  a.print();
  c.print();
}

