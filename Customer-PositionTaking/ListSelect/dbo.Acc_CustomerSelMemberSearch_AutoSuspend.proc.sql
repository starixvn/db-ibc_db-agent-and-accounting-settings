ALTER PROCEDURE [dbo].[Acc_CustomerSelMemberSearch_AutoSuspend]
	@Keyword nvarchar(50)='%',
	@FirstChar nvarchar(6)='%',
	@PageSize int=50,
	@PageIndex int=1,
	@TotalPages int=0 OUTPUT
AS
--@Pattern Explanation:
	--Search keyword: '%keyword%'
	--Frist char:
	--A: 'A%'
	--B: 'B%'
	--0-9: '[0-9]%'
SET NOCOUNT ON

DECLARE @RowCount int, @RowStart int, @RowEnd int
SELECT @PageIndex = @PageIndex - 1, @RowStart = @PageSize * @PageIndex + 1, @RowEnd = @RowStart + @PageSize - 1 

IF @TotalPages = 0
BEGIN
	SELECT @TotalPages = count(1),@TotalPages=@TotalPages/@PageSize + case when @TotalPages%@PageSize>0 then 1 else 0 end  

	FROM custinfo ci with (nolock) 
		inner join customer c with (nolock) on c.custid = ci.custid
	WHERE c.roleid = 1
		and c.username like @Keyword and c.username like @FirstChar
END
SELECT * FROM 
(
	SELECT c.username, c.CustID, autosuspend,
		c.firstname, c.lastname,ROW_NUMBER() OVER (ORDER by c.username ) as RowNumber
	FROM custinfo ci with (nolock) 
		inner join customer c with (nolock) on c.custid = ci.custid
	WHERE c.roleid = 1
		and c.username like @Keyword and c.username like @FirstChar
) a
WHERE a.RowNumber BETWEEN @RowStart AND @RowEnd

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMemberSearch_AutoSuspend] TO [bodbAdminNet]