/*
    Copyright (C) 2003 by Mat Sutcliffe <oktal@gmx.co.uk>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
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
 * @file   hash.h
 * @brief  A generic hash table
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_HASH_H__
#define __SAT_HASH_H__

//#include "satsysdef.h"

#include "macros.h"
#include "array.h"
#include "comparator.h"
#include "strutil.h"

/**@addtogroup base_common
 * @{ */

/**
 * Compute a hash key for a null-terminated string.
 * <p>
 * Note that these keys are non-unique; some dissimilar strings may generate
 * the same key. For unique keys, see StringSet.
 */
unsigned int HashCompute (char const*);

/**
 * Compute a hash key for a string of a given length.
 * <p>
 * Note that these keys are non-unique; some dissimilar strings may generate
 * the same key. For unique keys, see StringSet.
 */
unsigned int HashCompute (char const*, size_t length);

/**
 * Template for hash value computing.
 * Expects that T has a method 'uint GetHash() const'.
 */
template <class T>
class HashComputer
{
public:
  /// Compute a hash value for \a key.
  static uint ComputeHash (const T& key)
  {
    return key.GetHash();
  }
};

/**
 * Template for hash value computing, suitable for integral types and types
 * that can be casted to such.
 */
template <class T>
class HashComputerIntegral
{
public:
  /// Compute a hash value for \a key.
  static uint ComputeHash (const T& key)
  {
    return (uintptr_t)key;
  }
};

//@{
/**
 * HashComputer<> specialization for an integral type.
 */
template<>
class HashComputer<void*> : public HashComputerIntegral<void*> {};

template<>
class HashComputer<int> : public HashComputerIntegral<int> {};
template<>
class HashComputer<unsigned int> :
  public HashComputerIntegral<unsigned int> {};

template<>
class HashComputer<long> : public HashComputerIntegral<long> {};
template<>
class HashComputer<unsigned long> :
  public HashComputerIntegral<unsigned long> {};

// #if (SAT_LONG_SIZE < 8)
// template<>
// class HashComputer<longlong> :
//   public HashComputerIntegral<longlong> {};
// template<>
// class HashComputer<ulonglong> :
//   public HashComputerIntegral<ulonglong> {};
// #endif

template<>
class HashComputer<float>
{
public:
  /// Compute a hash value for \a key.
  static uint ComputeHash (float key)
  {
    union
    {
      float f;
      uint u;
    } float2uint;
    float2uint.f = key;
    return float2uint.u;
  }
};
template<>
class HashComputer<double>
{
public:
  /// Compute a hash value for \a key.
  static uint ComputeHash (double key)
  {
    union
    {
      double f;
      uint u;
    } double2uint;
    double2uint.f = key;
    return double2uint.u;
  }
};
//@}

/**
 * A helper template to use pointers as keys for hashes.
 */
template <typename T>
class PtrKey
{
  T* ptr;
public:
  PtrKey () : ptr(0) {}
  PtrKey (T* ptr) : ptr(ptr) {}
  PtrKey (PtrKey const& other) : ptr (other.ptr) {}

  uint GetHash () const { return (uintptr_t)ptr; }
  inline friend bool operator < (const PtrKey& r1, const PtrKey& r2)
  { return r1.ptr < r2.ptr; }
  operator T* () const
  { return ptr; }
  T* operator -> () const
  { return ptr; }
  PtrKey& operator = (PtrKey const& other)
  { ptr = other.ptr; return *this; }
};

/**
 * A helper template to use const pointers as keys for hashes.
 */
template <typename T>
class ConstPtrKey
{
  const T* ptr;
public:
  ConstPtrKey () : ptr(0) {}
  ConstPtrKey (const T* ptr) : ptr(ptr) {}
  ConstPtrKey (ConstPtrKey const& other) : ptr (other.ptr) {}

  uint GetHash () const { return (uintptr_t)ptr; }
  inline friend bool operator < (const ConstPtrKey& r1, const ConstPtrKey& r2)
  { return r1.ptr < r2.ptr; }
  operator const T* () const
  { return ptr; }
  const T* operator -> () const
  { return ptr; }
  ConstPtrKey& operator = (ConstPtrKey const& other)
  { ptr = other.ptr; return *this; }
};

/**
 * Template that can be used as a base class for hash computers for
 * string types (must support cast to const char*).
 * Example:
 * \code
 * template<> class HashComputer<MyString> :
 *   public HashComputerString<MyString> {};
 * \endcode
 */
template <class T>
class HashComputerString
{
public:
  static uint ComputeHash (const T& key)
  {
    return HashCompute ((const char*)key);
  }
};

/**
 * HashComputer<> specialization for strings that uses HashCompute().
 */
template<>
class HashComputer<const char*> : public HashComputerString<const char*> {};

/**
 * Template that can be used as a base class for hash computers for POD
 * structs.
 * Example:
 * \code
 * template<> class HashComputer<MyStruct> :
 *   public HashComputerStruct<MyStruct> {};
 * \endcode
 */
template <class T>
class HashComputerStruct
{
public:
  static uint ComputeHash (const T& key)
  {
    return HashCompute ((char*)&key, sizeof (T));
  }
};

/**
 * This is a simple helper class to make a copy of a const char*.
 * This can be used to have a hash that makes copies of the keys.
 * \deprecated String can also be used for hash keys.
 */
class StrKey
{
private:
  char* str;

public:
  StrKey () { str = 0; }
  StrKey (const char* s) { str = StrNew (s); }
  StrKey (const StrKey& c) { str = StrNew (c.str); }
  ~StrKey () { delete[] str; }
  StrKey& operator=(const StrKey& o)
  {
    delete[] str; str = StrNew (o.str);
    return *this;
  }
  operator const char* () const { return str; }
  uint GetHash() const { return HashCompute (str); }
};

/**
 * Comparator<> specialization for StrKey that uses strcmp().
 */
template<>
class Comparator<StrKey, StrKey> : public ComparatorString<StrKey> {};

/**
 * A generic hash table class,
 * which grows dynamically and whose buckets are unsorted arrays.
 * The hash value of a key is computed using HashComputer<>, two keys are
 * compared using Comparator<>. You need to provide appropriate
 * specializations of those templates if you want use non-integral types
 * (other than const char*, StrKey and String for which appropriate
 * specializations are already provided) or special hash algorithms.
 */
template <class T, class K = unsigned int,
  class ArrayMemoryAlloc = SAT::Memory::AllocatorMalloc>
class Hash
{
public:
  typedef Hash<T, K, ArrayMemoryAlloc> ThisType;
  typedef T ValueType;
  typedef K KeyType;
  typedef ArrayMemoryAlloc AllocatorType;

protected:
  struct Element
  {
    const K key;
    T value;

    Element (const K& key0, const T &value0) : key (key0), value (value0) {}
    Element (const Element &other) : key (other.key), value (other.value) {}
  };
  typedef Array<Element, ArrayElementHandler<Element>,
    ArrayMemoryAlloc> ElementArray;
  Array<ElementArray, ArrayElementHandler<ElementArray>,
    ArrayMemoryAlloc> Elements;

  size_t Modulo;

private:
  size_t InitModulo;
  size_t GrowRate;
  size_t MaxSize;
  size_t Size;

  void Grow ()
  {
    static const size_t Primes[] =
    {
      53,         97,         193,       389,       769,
      1543,       3079,       6151,      12289,     24593,
      49157,      98317,      196613,    393241,    786433,
      1572869,    3145739,    6291469,   12582917,  25165843,
      50331653,   100663319,  201326611, 402653189, 805306457,
      1610612741, 0
    };

    const size_t *p;
    size_t elen = Elements.GetSize ();
    for (p = Primes; *p && *p <= elen; p++) ;
    Modulo = *p;
    SAT_ASSERT (Modulo);

    Elements.SetSize (Modulo, ElementArray (0, MIN(Modulo / GrowRate, 4)));

    for (size_t i = 0; i < elen; i++)
    {
      ElementArray& src = Elements[i];
      size_t slen = src.GetSize ();
      for (size_t j = slen; j > 0; j--)
      {
        const Element& srcElem = src[j - 1];
        ElementArray& dst =
	  Elements.Get (HashComputer<K>::ComputeHash (srcElem.key) % Modulo);
        if (&src != &dst)
        {
          dst.Push (srcElem);
          src.DeleteIndex (j - 1);
        }
      }
    }
  }

public:
  /**
   * Construct a hash table with an array of the given size,
   * which for optimisation reasons should be a prime number.
   *
   * \a grow_rate is the rate at which the hash table grows:
   * \a size doubles once there are \a size/\a grow_rate collisions.
   * It will not grow after it reaches \a max_size.
   *
   * Here are a few primes: 7, 11, 19, 29, 59, 79, 101, 127, 151, 199, 251,
   * 307, 401, 503, 809, 1009, 1499, 2003, 3001, 5003, 12263, 25247, 36923,
   * 50119, 70951, 90313, 104707.
   *
   * For a bigger list go to http://www.utm.edu/research/primes/
   */
  Hash (size_t size = 23, size_t grow_rate = 5, size_t max_size = 20000)
    : Modulo (size), InitModulo (size),
      GrowRate (MIN (grow_rate, size)), MaxSize (max_size), Size (0)
  {
  }

  /// Copy constructor.
  Hash (const Hash<T> &o) : Elements (o.Elements),
    Modulo (o.Modulo), InitModulo (o.InitModulo),
    GrowRate (o.GrowRate), MaxSize (o.MaxSize), Size (o.Size) {}

  /**
   * Add an element to the hash table.
   * \remarks If `key' is already present, does NOT replace the existing value,
   *   but merely adds `value' as an additional value of `key'. To retrieve all
   *   values for a given key, use GetAll(). If you instead want to replace an
   *   existing value for 'key', use PutUnique().
   */
  void Put (const K& key, const T &value)
  {
    if (Elements.GetSize() == 0) Elements.SetSize (Modulo);
    ElementArray& values =
      Elements[HashComputer<K>::ComputeHash (key) % Modulo];
    values.Push (Element (key, value));
    Size++;
    if (values.GetSize () > Elements.GetSize () / GrowRate
     && Elements.GetSize () < MaxSize) Grow ();
  }

  /// Get all the elements with the given key, or empty if there are none.
  Array<T> GetAll (const K& key) const
  {
    return GetAll<typename Array<T>::ElementHandlerType,
      typename Array<T>::AllocatorType> (key);
  }

  /// Get all the elements with the given key, or empty if there are none.
  template<typename H, typename M>
  Array<T, H, M> GetAll (const K& key) const
  {
    if (Elements.GetSize() == 0) return Array<T> ();
    const ElementArray& values =
      Elements[HashComputer<K>::ComputeHash (key) % Modulo];
    Array<T> ret (values.GetSize () / 2);
    const size_t len = values.GetSize ();
    for (size_t i = 0; i < len; ++i)
    {
      const Element& v = values[i];
      if (Comparator<K, K>::Compare (v.key, key) == 0)
	ret.Push (v.value);
    }
    return ret;
  }

  /// Add an element to the hash table, overwriting if the key already exists.
  void PutUnique (const K& key, const T &value)
  {
    if (Elements.GetSize() == 0) Elements.SetSize (Modulo);
    ElementArray& values =
      Elements[HashComputer<K>::ComputeHash (key) % Modulo];
    const size_t len = values.GetSize ();
    for (size_t i = 0; i < len; ++i)
    {
      Element& v = values[i];
      if (Comparator<K, K>::Compare (v.key, key) == 0)
      {
        v.value = value;
        return;
      }
    }

    values.Push (Element (key, value));
    Size++;
    if (values.GetSize () > Elements.GetSize () / GrowRate
     && Elements.GetSize () < MaxSize) Grow ();
  }

  /// Returns whether at least one element matches the given key.
  bool Contains (const K& key) const
  {
    if (Elements.GetSize() == 0) return false;
    const ElementArray& values =
      Elements[HashComputer<K>::ComputeHash (key) % Modulo];
    const size_t len = values.GetSize ();
    for (size_t i = 0; i < len; ++i)
      if (Comparator<K, K>::Compare (values[i].key, key) == 0)
	return true;
    return false;
  }

  /**
   * Returns whether at least one element matches the given key.
   * \remarks This is rigidly equivalent to Contains(key), but may be
   *   considered more idiomatic by some.
   */
  bool In (const K& key) const
  { return Contains(key); }

  /**
   * Get a pointer to the first element matching the given key,
   * or 0 if there is none.
   */
  const T* GetElementPointer (const K& key) const
  {
    if (Elements.GetSize() == 0) return 0;
    const ElementArray& values =
      Elements[HashComputer<K>::ComputeHash (key) % Modulo];
    const size_t len = values.GetSize ();
    for (size_t i = 0; i < len; ++i)
    {
      const Element& v = values[i];
      if (Comparator<K, K>::Compare (v.key, key) == 0)
	return &v.value;
    }

    return 0;
  }

  /**
   * Get a pointer to the first element matching the given key,
   * or 0 if there is none.
   */
  T* GetElementPointer (const K& key)
  {
    if (Elements.GetSize() == 0) return 0;
    ElementArray& values =
      Elements[HashComputer<K>::ComputeHash (key) % Modulo];
    const size_t len = values.GetSize ();
    for (size_t i = 0; i < len; ++i)
    {
      Element& v = values[i];
      if (Comparator<K, K>::Compare (v.key, key) == 0)
	return &v.value;
    }

    return 0;
  }

  /**
   * Get the first element matching the given key, or \p fallback if there is
   * none.
   */
  const T& Get (const K& key, const T& fallback) const
  {
    if (Elements.GetSize() == 0) return fallback;
    const ElementArray& values =
      Elements[HashComputer<K>::ComputeHash (key) % Modulo];
    const size_t len = values.GetSize ();
    for (size_t i = 0; i < len; ++i)
    {
      const Element& v = values[i];
      if (Comparator<K, K>::Compare (v.key, key) == 0)
	return v.value;
    }

    return fallback;
  }

  /**
   * Get the first element matching the given key, or \p fallback if there is
   * none.
   */
  T& Get (const K& key, T& fallback)
  {
    if (Elements.GetSize() == 0) return fallback;
    ElementArray& values =
      Elements[HashComputer<K>::ComputeHash (key) % Modulo];
    const size_t len = values.GetSize ();
    for (size_t i = 0; i < len; ++i)
    {
      Element& v = values[i];
      if (Comparator<K, K>::Compare (v.key, key) == 0)
	return v.value;
    }

    return fallback;
  }

  /// Delete all the elements.
  void DeleteAll ()
  {
    Elements.DeleteAll();
    Modulo = InitModulo;
    Size = 0;
  }

  /// Delete all the elements. (Idiomatic alias for DeleteAll().)
  void Empty() { DeleteAll(); }

  /// Delete all the elements matching the given key.
  bool DeleteAll (const K& key)
  {
    bool ret = false;
    if (Elements.GetSize() == 0) return ret;
    ElementArray& values =
      Elements[HashComputer<K>::ComputeHash (key) % Modulo];
    for (size_t i = values.GetSize (); i > 0; i--)
    {
      const size_t idx = i - 1;
      if (Comparator<K, K>::Compare (values[idx].key, key) == 0)
      {
	values.DeleteIndexFast (idx);
        ret = true;
        Size--;
      }
    }
    return ret;
  }

  /// Delete all the elements matching the given key and value.
  bool Delete (const K& key, const T &value)
  {
    bool ret = false;
    if (Elements.GetSize() == 0) return ret;
    ElementArray& values =
      Elements[HashComputer<K>::ComputeHash (key) % Modulo];
    for (size_t i = values.GetSize (); i > 0; i--)
    {
      const size_t idx = i - 1;
      if ((Comparator<K, K>::Compare (values[idx].key, key) == 0) &&
	  (Comparator<T, T>::Compare (values[idx].value, value) == 0 ))
      {
        values.DeleteIndexFast (idx);
        ret = true;
        Size--;
      }
    }
    return ret;
  }

  /// Get the number of elements in the hash.
  size_t GetSize () const
  {
    return Size;
  }

  /**
   * Return true if the hash is empty.
   * \remarks Rigidly equivalent to <tt>return GetSize() == 0</tt>, but more
   *   idiomatic.
   */
  bool IsEmpty() const
  {
    return GetSize() == 0;
  }

  /// An iterator class for the hash.
  class Iterator
  {
  private:
    Hash<T, K>* hash;
    const K key;
    size_t bucket, size, element;

    void Seek ()
    {
      while ((element < size) &&
        (Comparator<K, K>::Compare (hash->Elements[bucket][element].key,
	key) != 0))
          element++;
    }

  protected:
    Iterator (Hash<T, K>* hash0, const K& key0) :
      hash(hash0),
      key(key0),
      bucket(HashComputer<K>::ComputeHash (key) % hash->Modulo),
      size((hash->Elements.GetSize() > 0) ? hash->Elements[bucket].GetSize () : 0)
      { Reset (); }

    friend class Hash<T, K>;
  public:
    /// Copy constructor.
    Iterator (const Iterator &o) :
      hash (o.hash),
      key(o.key),
      bucket(o.bucket),
      size(o.size),
      element(o.element) {}

    /// Assignment operator.
    Iterator& operator=(const Iterator& o)
    {
      hash = o.hash;
      key = o.key;
      bucket = o.bucket;
      size = o.size;
      element = o.element;
      return *this;
    }

    /// Returns a boolean indicating whether or not the hash has more elements.
    bool HasNext () const
    {
      return element < size;
    }

    /// Get the next element's value.
    T& Next ()
    {
      T &ret = hash->Elements[bucket][element].value;
      element++;
      Seek ();
      return ret;
    }

    /// Move the iterator back to the first element.
    void Reset () { element = 0; Seek (); }
  };
  friend class Iterator;

  /// An iterator class for the hash.
  class GlobalIterator
  {
  private:
    Hash<T, K> *hash;
    size_t bucket, size, element;

    void Zero () { bucket = element = 0; }
    void Init ()
    {
      size =
        (hash->Elements.GetSize() > 0) ? hash->Elements[bucket].GetSize () : 0;
    }

    void FindItem ()
    {
      if (element >= size)
      {
	while (++bucket < hash->Elements.GetSize ())
	{
          Init ();
	  if (size != 0)
	  {
	    element = 0;
	    break;
	  }
	}
      }
    }

  protected:
    GlobalIterator (Hash<T, K> *hash0) : hash (hash0)
    {
      Zero ();
      Init ();
      FindItem ();
    }

    friend class Hash<T, K>;
  public:
    /// Copy constructor.
    GlobalIterator (const GlobalIterator &o) :
      hash (o.hash),
      bucket (o.bucket),
      size (o.size),
      element (o.element) {}

    /// Assignment operator.
    GlobalIterator& operator=(const GlobalIterator& o)
    {
      hash = o.hash;
      bucket = o.bucket;
      size = o.size;
      element = o.element;
      return *this;
    }

    /// Returns a boolean indicating whether or not the hash has more elements.
    bool HasNext () const
    {
      if (hash->Elements.GetSize () == 0) return false;
      return element < size || bucket < hash->Elements.GetSize ();
    }

    /// Advance the iterator of one step
    void Advance ()
    {
      element++;
      FindItem ();
    }

    /// Get the next element's value, don't move the iterator.
    T& NextNoAdvance ()
    {
      return hash->Elements[bucket][element].value;
    }

    /// Get the next element's value.
    T& Next ()
    {
      T &ret = NextNoAdvance ();
      Advance ();
      return ret;
    }

    /// Get the next element's value and key, don't move the iterator.
    T& NextNoAdvance (K &key)
    {
      key = hash->Elements[bucket][element].key;
      return NextNoAdvance ();
    }

    /// Get the next element's value and key.
    T& Next (K &key)
    {
      key = hash->Elements[bucket][element].key;
      return Next ();
    }

    /// Move the iterator back to the first element.
    void Reset () { Zero (); Init (); FindItem (); }
  };
  friend class GlobalIterator;

  /// An const iterator class for the hash.
  class ConstIterator
  {
  private:
    const Hash<T, K>* hash;
    const K key;
    size_t bucket, size, element;

    void Seek ()
    {
      while ((element < size) &&
        (Comparator<K, K>::Compare (hash->Elements[bucket][element].key,
	key) != 0))
          element++;
    }

  protected:
    ConstIterator (const Hash<T, K>* hash0, const K& key0) :
      hash(hash0),
      key(key0),
      bucket(HashComputer<K>::ComputeHash (key) % hash->Modulo),
      size((hash->Elements.GetSize() > 0) ? hash->Elements[bucket].GetSize () : 0)
      { Reset (); }

    friend class Hash<T, K>;
  public:
    /// Copy constructor.
    ConstIterator (const ConstIterator &o) :
      hash (o.hash),
      key(o.key),
      bucket(o.bucket),
      size(o.size),
      element(o.element) {}

    /// Assignment operator.
    ConstIterator& operator=(const ConstIterator& o)
    {
      hash = o.hash;
      key = o.key;
      bucket = o.bucket;
      size = o.size;
      element = o.element;
      return *this;
    }

    /// Returns a boolean indicating whether or not the hash has more elements.
    bool HasNext () const
    {
      return element < size;
    }

    /// Get the next element's value.
    const T& Next ()
    {
      const T &ret = hash->Elements[bucket][element].value;
      element++;
      Seek ();
      return ret;
    }

    /// Move the iterator back to the first element.
    void Reset () { element = 0; Seek (); }
  };
  friend class ConstIterator;

  /// An const iterator class for the hash.
  class ConstGlobalIterator
  {
  private:
    const Hash<T, K> *hash;
    size_t bucket, size, element;

    void Zero () { bucket = element = 0; }
    void Init ()
    {
      size =
        (hash->Elements.GetSize() > 0) ? hash->Elements[bucket].GetSize () : 0;
    }

    void FindItem ()
    {
      if (element >= size)
      {
	while (++bucket < hash->Elements.GetSize ())
	{
          Init ();
	  if (size != 0)
	  {
	    element = 0;
	    break;
	  }
	}
      }
    }

  protected:
    ConstGlobalIterator (const Hash<T, K> *hash0) : hash (hash0)
    {
      Zero ();
      Init ();
      FindItem ();
    }

    friend class Hash<T, K>;
  public:
    /// Copy constructor.
    ConstGlobalIterator (const ConstGlobalIterator &o) :
      hash (o.hash),
      bucket (o.bucket),
      size (o.size),
      element (o.element) {}

    /// Assignment operator.
    ConstGlobalIterator& operator=(const ConstGlobalIterator& o)
    {
      hash = o.hash;
      bucket = o.bucket;
      size = o.size;
      element = o.element;
      return *this;
    }

    /// Returns a boolean indicating whether or not the hash has more elements.
    bool HasNext () const
    {
      if (hash->Elements.GetSize () == 0) return false;
      return element < size || bucket < hash->Elements.GetSize ();
    }

    /// Advance the iterator of one step
    void Advance ()
    {
      element++;
      FindItem ();
    }

    /// Get the next element's value, don't move the iterator.
    const T& NextNoAdvance ()
    {
      return hash->Elements[bucket][element].value;
    }

    /// Get the next element's value.
    const T& Next ()
    {
      const T &ret = NextNoAdvance ();
      Advance ();
      return ret;
    }

    /// Get the next element's value and key, don't move the iterator.
    const T& NextNoAdvance (K &key)
    {
      key = hash->Elements[bucket][element].key;
      return NextNoAdvance ();
    }

    /// Get the next element's value and key.
    const T& Next (K &key)
    {
      key = hash->Elements[bucket][element].key;
      return Next ();
    }

    /// Move the iterator back to the first element.
    void Reset () { Zero (); Init (); FindItem (); }
  };
  friend class ConstGlobalIterator;

  /// Delete the element pointed by the iterator. This is safe for this
  /// iterator, not for the others.
  void DeleteElement (GlobalIterator& iterator)
  {
    Elements[iterator.bucket].DeleteIndex(iterator.element);
    Size--;
    iterator.size--;
    iterator.FindItem ();
  }

  /// Delete the element pointed by the iterator. This is safe for this
  /// iterator, not for the others.
  void DeleteElement (ConstGlobalIterator& iterator)
  {
    Elements[iterator.bucket].DeleteIndex(iterator.element);
    Size--;
    iterator.size--;
    iterator.FindItem ();
  }

  /**
   * Return an iterator for the hash, to iterate only over the elements
   * with the given key.
   * \warning Modifying the hash (except with DeleteElement()) while you have
   *   open iterators will result in undefined behaviour.
   */
  Iterator GetIterator (const K& key)
  {
    return Iterator (this, key);
  }

  /**
   * Return an iterator for the hash, to iterate over all elements.
   * \warning Modifying the hash (except with DeleteElement()) while you have
   *   open iterators will result in undefined behaviour.
   */
  GlobalIterator GetIterator ()
  {
    return GlobalIterator (this);
  }

  /**
   * Return a const iterator for the hash, to iterate only over the elements
   * with the given key.
   * \warning Modifying the hash (except with DeleteElement()) while you have
   *   open iterators will result in undefined behaviour.
   */
  ConstIterator GetIterator (const K& key) const
  {
    return ConstIterator (this, key);
  }

  /**
   * Return a const iterator for the hash, to iterate over all elements.
   * \warning Modifying the hash (except with DeleteElement()) while you have
   *   open iterators will result in undefined behaviour.
   */
  ConstGlobalIterator GetIterator () const
  {
    return ConstGlobalIterator (this);
  }
};

/** @} */

#endif
