class ListNode(object):
    def __init__(self, val=0, next=None):
        self.val = val
        self.next = next

class Solution:
    def mergeTwoLists(self, list1, list2):
        if list1.val < list2.val:
            rlist = ListNode(list1.val, None)
            list1 = list1.next
        else:
            rlist = ListNode(list2.val, None)
            list2 = list2.next

        head = prev = rlist

        while list1.next != None and list2.next != None:
            if list1.val < list2.val:
                prev.next = ListNode(list1.val, None)
                prev = prev.next
                list1 = list1.next
            else:
                prev.next = ListNode(list2.val, None)
                prev = prev.next
                list2 = list2.next

        return head


# tests:
def test():
    list1 = ListNode(1, ListNode(2, ListNode(4)))
    list2 = ListNode(1, ListNode(3, ListNode(4)))
    s = Solution()
    result = s.mergeTwoLists(list1, list2)
    while result:
        print(result.val)
        result = result.next
        
test()