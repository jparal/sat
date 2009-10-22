/*
    Copyright (C) 2003 by Marten Svanfeldt
    influenced by Aapl by Adrian Thurston <adriant@ragel.ca>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/
/**
 * @file   list.h
 * @brief  Simple double-linked list template implementation
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */
#ifndef __SAT_LIST_H__
#define __SAT_LIST_H__

#include "base/sys/assert.h"

/// @addtogroup base_common
/// @{

/**
 * A lightweight double-linked list template.  Copies the elements into the
 * list for storages.  Assumes that type T supports copy construction.
 */
template <class T>
class List
{
protected:
  /**
   * Template which describes the data stored in the linked list.
   * For example a list of ints uses ListElement<int>.
   */
  struct ListElement
  {
    /// Use specified data
    ListElement(const T& d, ListElement* newnext, ListElement* newprev) :
      next(newnext), prev(newprev), data(d) {}

    /// Next element in list. If this is the last one, then next is 0
    ListElement* next;

    /// Previous element in list. If this is the first one, prev is 0
    ListElement* prev;

    /// Stored data
    T data;
  };

  /// Remove specific item by explicit ref
  void Delete (ListElement *el);

public:
  /// Default constructor
  List() : head(0), tail(0) {}

  /// Copy constructor
  List(const List<T> &other);

  /// Destructor
  ~List()
  { DeleteAll (); }

  /// Iterator for the list
  class Iterator
  {
  public:
    /// Constructor
    Iterator() : ptr(0), visited(false), reversed(false)
    { }
    /// Copy constructor
    Iterator(const Iterator& r)
    { ptr = r.ptr; visited = r.visited; reversed = r.reversed; }
    /// Constructor.
    Iterator(const List<T> &list, bool reverse = false) :
      visited(false), reversed(reverse)
    {
      if (reverse) ptr = list.tail;
      else ptr = list.head;
    }
    /// Assignment operator
    Iterator& operator= (const Iterator& r)
    { ptr = r.ptr; visited = r.visited; reversed = r.reversed; return *this; }
    /// Test if the Iterator is set to a valid element.
    bool HasCurrent() const
    { return visited && ptr != 0; }
    /// Test if there is a next element.
    bool HasNext() const
    { return ptr && (ptr->next || !visited); }
    /// Test if there is a previous element.
    bool HasPrevious() const
    { return ptr && (ptr->prev || !visited); }
    /// Test if the Iterator is set to the first element.
    bool IsFirst() const
    { return ptr && ptr->prev == 0; }
    /// Test if the Iterator is set to the last element.
    bool IsLast() const
    { return ptr && ptr->next == 0; }
    /// Test if the iterator is reversed.
    bool IsReverse() const
    { return reversed; }

    /// Cast operator.
    operator T*() const
    { return visited && ptr ? &ptr->data : 0; }
    /// Dereference operator (*).
    T& operator *() const
    { SAT_ASSERT(ptr != 0); return ptr->data; }
    /// Dereference operator (->).
    T* operator->() const
    { return visited && ptr ? &ptr->data : 0; }

    /// Set iterator to non-existent element. HasCurrent() will return false.
    void Clear ()
    {
      ptr = 0;
      visited = true;
    }
    /// Advance to next element and return it.
    T& Next ()
    {
      if (visited && ptr != 0)
        ptr = ptr->next;
      visited = true;
      SAT_ASSERT(ptr != 0);
      return ptr->data;
    }
    /// Backup to previous element and return it.
    T& Previous()
    {
      if (visited && ptr != 0)
        ptr = ptr->prev;
      visited = true;
      SAT_ASSERT(ptr != 0);
      return ptr->data;
    }
    T& Prev() { return Previous(); } // Backward compatibility.

    /// Advance to next element and return it.
    Iterator& operator++()
    {
      if (visited && ptr != 0)
        ptr = ptr->next;
      visited = true;
      return *this;
    }
    /// Backup to previous element and return it.
    Iterator& operator--()
    {
      if (visited && ptr != 0)
        ptr = ptr->prev;
      visited = true;
      return *this;
    }

    /**
     * Return current element.
     * Warning! Assumes there is a current element!
     */
    T& FetchCurrent () const
    {
      SAT_ASSERT(visited && ptr != 0);
      return ptr->data;
    }
    /**
     * Return next element but don't modify iterator.
     * Warning! Assumes there is a next element!
     */
    T& FetchNext () const
    {
      SAT_ASSERT(ptr != 0);
      return visited ? ptr->next->data : ptr->data;
    }
    /**
     * Return previous element but don't modify iterator.
     * Warning! Assumes there is a previous element!
     */
    T& FetchPrevious () const
    {
      SAT_ASSERT(ptr != 0);
      return visited ? ptr->prev->data : ptr->data;
    }
    T& FetchPrev () const { return FetchPrevious(); } // Backward compat.

  protected:
    friend class List<T>;
    Iterator (ListElement* element, bool visit = true, bool rev = false) :
      ptr(element), visited(visit), reversed(rev)
    {}

  private:
    ListElement* ptr;
    bool visited;
    bool reversed;
  };

  /// Assignment, shallow copy.
  List& operator=(const List<T>& other);

  /// Add an item first in list. Copy T into the listdata.
  Iterator PushFront (const T& item);

  /// Add an item last in list. Copy T into the listdata.
  Iterator PushBack (const T& item);

  /// Insert an item before the item the iterator is set to.
  void InsertBefore(Iterator& it, const T& item);

  /// Insert an item after the item the iterator is set to.
  void InsertAfter(Iterator& it, const T& item);

  /// Move an item (as iterator) before the item the iterator is set to.
  void MoveBefore(const Iterator& it, const Iterator& item);

  /// Move an item (as iterator) after the item the iterator is set to.
  void MoveAfter(const Iterator& it, const Iterator& item);

  /// Remove specific item by iterator.
  void Delete (Iterator& it);

  /// Empty an list.
  void DeleteAll();

  /// Return first element of the list.
  T& Front () const
  { return head->data; }
  /// Return last element of the list.
  T& Last () const
  { return tail->data; }

  /// Deletes the first element of the list.
  bool PopFront ()
  {
    if (!head)
      return false;
    Delete (head);
    return true;
  }

  /// Deletes the last element of the list
  bool PopBack ()
  {
    if (!tail)
      return false;
    Delete (tail);
    return true;
  }

  bool IsEmpty () const
  {
    SAT_ASSERT((head == 0 && tail == 0) || (head !=0 && tail != 0));
    return head == 0;
  }

private:
  friend class Iterator;
  ListElement *head, *tail;
};

#include "list.cpp"

/// @}

#endif /* __SAT_LIST_H__ */
