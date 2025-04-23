namespace MicroA.Domain.DTO
{
    public class UpdateUserDto
    {
        public Guid Id { get; set; }
        public string Name {  get; set; }
        public string Surname { get; set; }
        public string Email { get; set; }

        public UpdateUserDto(Guid id, string name, string surname, string email) 
        { 
            Id = id;
            Name = name;
            Surname = surname;
            Email = email;
        }
    }
}
