MatchaChat
==========

An instant message iOS application, based on XMPP


There are things to notice if you try to run this application:

1. The libidn in MatchaChat/Libs/XMPPFramework/Vendor/ has to be readded to the project, or it could cause error while compiling.
2. There is a problem in XMPPFramework supplied by XMPP official organization. The problem is that the delegate method xmppStreamDidAuthenticate and xmppStream:didNotAuthenticate: will not be called after invoking [_xmppStream authenticateWithPassword:error:]. I've done some researches via Google, Stackoverflow and other communities, but this problem still can not be soluted. The only info I got from my research is the official XMPPFramework exist this problem, but it hasn't been proved. If you have solution, please feel free to contact me, comeonjiji@gmail.com, thank you!
