package Decorator;

import Item.*;
import java.awt.*;

import Point.*;
import Point.Point;

public abstract class Decorator extends Item{
    protected Item item;
    public Decorator(Item item){
        super(item.getPosition());
        this.item = item;
    }
    public Item getItem(){
        return item;
    }
    public void setItem(Item item){
        this.item = item;
    }
    @Override
    public String getItemInfo(){
        return item.getItemInfo();
    }
    @Override
    public BoundingBox calculateBoundingBox(){
        return item.calculateBoundingBox();
    }
    @Override
    public void translate(Point p){
        item.translate(p);
    }
    @Override
    public void draw(Graphics2D g){
        item.draw(g);
    }
}
