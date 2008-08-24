/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   list.cpp
 * @brief  Inline methods for List<T>
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

/// Deep copy of list
template <class T>
inline List<T>::List(const List<T> &other) : head(0), tail(0)
{
  ListElement* e = other.head;
  while (e != 0)
  {
    PushBack (e->data);
    e = e->next;
  }
}

/// Assignment, deep-copy
template <class T>
inline List<T>& List<T>::operator= (const List<T> &other)
{
  DeleteAll ();
  ListElement* e = other.head;
  while (e != 0)
  {
    PushBack (e->data);
    e = e->next;
  }
  return *this;
}

/// Delete all elements
template <class T>
inline void List<T>::DeleteAll ()
{
  ListElement *cur = head, *next = 0;
  while (cur != 0)
  {
    next = cur->next;
    delete cur;
    cur = next;
  }
  head = tail = 0;
}

/// Add one item last in the list
template <class T>
inline typename List<T>::Iterator List<T>::PushBack (const T& e)
{
  ListElement* el = new ListElement (e, 0, tail);
  if (tail)
    tail->next = el;
  else
    head = el;
  tail = el;
  return Iterator(el);
}

/// Add one item first in the list
template <class T>
inline typename List<T>::Iterator List<T>::PushFront (const T& e)
{
  ListElement* el = new ListElement (e, head, 0);
  if (head)
    head->prev = el;
  else
    tail = el;
  head = el;
  return Iterator (el);
}

template <class T>
inline void List<T>::InsertAfter (Iterator &it, const T& item)
{
  SAT_ASSERT(it.HasCurrent());
  ListElement* el = it.ptr;
  ListElement* next = el->next;
  ListElement* prev = el;
  ListElement* newEl = new ListElement (item, next, prev);
  if (!next) // this is the last element
    tail = newEl;
  else
    el->next->prev = newEl;
  el->next = newEl;
}

template <class T>
inline void List<T>::InsertBefore (Iterator &it, const T& item)
{
  SAT_ASSERT(it.HasCurrent());
  ListElement* el = it.ptr;
  ListElement* next = el;
  ListElement* prev = el->prev;
  ListElement* newEl = new ListElement (item, next, prev);
  if (!prev) // this is the first element
    head = newEl;
  else
    el->prev->next = newEl;
  el->prev = newEl;
}

template <class T>
inline void List<T>::MoveAfter (const Iterator &it, const Iterator &item)
{
  SAT_ASSERT(item.HasCurrent());
  ListElement* el_item = item.ptr;

  // Unlink the item.
  if (el_item->prev)
    el_item->prev->next = el_item->next;
  else
    head = el_item->next;
  if (el_item->next)
    el_item->next->prev = el_item->prev;
  else
    tail = el_item->prev;

  SAT_ASSERT(it.HasCurrent());
  ListElement* el = it.ptr;
  ListElement* next = el->next;
  ListElement* prev = el;

  el_item->next = next;
  el_item->prev = prev;
  if (!next) // this is the last element
    tail = el_item;
  else
    el->next->prev = el_item;
  el->next = el_item;
}

template <class T>
inline void List<T>::MoveBefore (const Iterator &it, const Iterator &item)
{
  SAT_ASSERT(item.HasCurrent());
  ListElement* el_item = item.ptr;

  // Unlink the item.
  if (el_item->prev)
    el_item->prev->next = el_item->next;
  else
    head = el_item->next;
  if (el_item->next)
    el_item->next->prev = el_item->prev;
  else
    tail = el_item->prev;

  SAT_ASSERT(it.HasCurrent());
  ListElement* el = it.ptr;
  ListElement* next = el;
  ListElement* prev = el->prev;

  el_item->next = next;
  el_item->prev = prev;
  if (!prev) // this is the first element
    head = el_item;
  else
    el->prev->next = el_item;
  el->prev = el_item;
}

template <class T>
inline void List<T>::Delete (Iterator &it)
{
  SAT_ASSERT(it.HasCurrent());
  ListElement* el = it.ptr;

  // Advance the iterator so we can delete the data it's using
  if (it.IsReverse())
    --it;
  else
    ++it;

  Delete(el);
}

template <class T>
inline void List<T>::Delete (ListElement *el)
{
  SAT_ASSERT(el != 0);

  // Fix the pointers of the 2 surrounding elements
  if (el->prev)
    el->prev->next = el->next;
  else
    head = el->next;

  if (el->next)
    el->next->prev = el->prev;
  else
    tail = el->prev;

  delete el;
}
