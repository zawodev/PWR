package Exercise3.ActorMsgs;

import Exercise3.Resources.ResourceType;
import Exercise3.Tools.Pair;
import akka.actor.ActorRef;

import java.util.ArrayList;

public record TransferRuleMsg(ArrayList<Pair<ActorRef, ResourceType>> transferRules) {}
