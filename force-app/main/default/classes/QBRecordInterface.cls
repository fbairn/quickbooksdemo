public abstract class QBRecordInterface {
    public abstract String endpoint();
    public virtual String qbObject(){
        return this.endpoint();
    }

    public virtual String minorversion(){
        return '40';
    }

    public virtual String serialize(){
        //This allows the serialization method to be overridden for certain types of objects.
        return JSON.serialize(this);
    }
}