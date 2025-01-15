namespace NewRazorApplication1.Models {
    public class ApiKey {
        public int Id { get; set; }
        public string Key { get; set; }
        public string Owner { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsActive { get; set; }
    }

}
