using System.Net.Sockets;

namespace OscJack;

public sealed partial class OscClient
{
    public void Send(string address, string serial, float x, float y, float z, float qx, float qy, float qz, float qw)
    {
        _encoder.Clear();
        _encoder.Append(address);
        _encoder.Append(",sfffffff");
        _encoder.Append(serial);
        _encoder.Append(x);
        _encoder.Append(y);
        _encoder.Append(z);
        _encoder.Append(qx);
        _encoder.Append(qy);
        _encoder.Append(qz);
        _encoder.Append(qw);
        _socket.Send(_encoder.Buffer, _encoder.Length, SocketFlags.None);
    }
}
