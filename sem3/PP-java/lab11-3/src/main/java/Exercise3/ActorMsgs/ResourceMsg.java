package Exercise3.ActorMsgs;

import Exercise3.Resources.Resource;
import akka.actor.ActorRef;
import Exercise3.Resources.ResourceType;

public record ResourceMsg (Resource resource) {}
